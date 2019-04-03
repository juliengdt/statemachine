//
//  RepositioningManager.swift
//  com.statemachine.repositioning
//
//  Created by Julien Goudet on 02/04/2019.
//  Copyright © 2019 Hootcode. All rights reserved.
//

import Foundation
import SwiftState


enum RepositioningMachineState: StateType, CustomDebugStringConvertible, CustomStringConvertible {
    case initial
    case needInfos(type: PositionHelperNeedHelpType, position: UserPosition)
    case needAffine(type: PositionHelperRepositioningType, position: UserPosition) // need z or whole x,y,z
    case projected(position: UserPosition)
    case final(position: UserPosition, mode: PositionHelperRoutingPrecisionType)
    case aborted

    
    static func == (lhs: RepositioningMachineState, rhs: RepositioningMachineState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
             (.aborted, .aborted):
            return true
        case (.needInfos(let lhs_type, let lhs_position), .needInfos(let rhs_type, let rhs_position)):
            return ((lhs_type == rhs_type) && (lhs_position == rhs_position))
        case (.needAffine(let lhs_type, let lhs_position), .needAffine(let rhs_type, let rhs_position)):
            return ((lhs_type == rhs_type) && (lhs_position == rhs_position))
        case (.projected(let lhs_position), .projected(let rhs_position)):
            return (lhs_position == rhs_position)
        case (.final(let lhs_position, let lhs_mode), .final(let rhs_position, let rhs_mode)):
            return ((lhs_mode == rhs_mode) && (lhs_position == rhs_position))
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
            case .initial:
                break
            case .needInfos(let type, let userPosition):
                hasher.combine(type)
                hasher.combine(userPosition)
            case .needAffine(let type, let userPosition):
                hasher.combine(type)
                hasher.combine(userPosition)
            case .projected(let userPosition):
                hasher.combine(userPosition)
            case .final(let userPosition, let mode):
                hasher.combine(mode)
                hasher.combine(userPosition)
            case .aborted:
                break
        }
    }
    
    var description: String {
        switch self {
        case .initial:
            return "initial"
        case .needInfos:
            return "needInfos"
        case .needAffine:
            return "needAffine"
        case .projected:
            return "projected"
        case .final:
            return "final"
        case .aborted:
            return "aborted"
        }
    }
    
    var debugDescription: String {
        switch self {
        case .initial:
            return "initial"
        case .needInfos(let type, let userPosition):
            return "needInfos -- type(\(type), userPosition(\(userPosition)))"
        case .needAffine(let type, let userPosition):
            return "needAffine -- type(\(type)), userPosition(\(userPosition)))"
        case .projected(let userPosition):
            return "projected -- userPosition(\(userPosition)))"
        case .final(let userPosition, let mode):
            return "final -- userPosition(\(userPosition)), mode(\(mode)))"
        case .aborted:
            return "aborted"
        }
    }
    
}
enum RepositioningMachineEvent: EventType {
    case start(position: UserPosition, type: RepositioningType)
    case moreInfos(type: PositionHelperNeedHelpType, value: Bool)
    case locationAffined(type: PositionHelperRepositioningType, position: UserPosition) // user has given Z or whole x,y,z
    case confirm(position: UserPosition)
    case force(position: UserPosition)
    
    static func == (lhs: RepositioningMachineEvent, rhs: RepositioningMachineEvent) -> Bool {
        return true
    }
    
    func hash(into hasher: inout Hasher) {
        
        switch self {
        case .start(let position, let type):
            hasher.combine(position)
            hasher.combine(type)
        case .moreInfos(let type, let decision):
            hasher.combine(type)
            hasher.combine(decision)
        case .locationAffined(let type, let position):
            hasher.combine(type)
            hasher.combine(position)
        case .confirm(let position):
            hasher.combine(position)
        case .force(let position):
            hasher.combine(position)
        }
    }
}


protocol RepositioningManagerInstance: PositionHelperInternalDatasource {
    var systemDelegate: PositionHelperInternalDelegate? { get set }
}


class RepositioningManager {
    
    typealias RepositioningMachine = Machine<RepositioningMachineState,RepositioningMachineEvent>
    
    static let instance: RepositioningManagerInstance = RepositioningManager()
    
    private weak var delegate: PositionHelperInternalDelegate?
    let machine: RepositioningMachine
    
    init() {
        
        machine = Machine<RepositioningMachineState,RepositioningMachineEvent>(state: .initial, initClosure: { fury in

            fury.addRouteMapping({ (givenEvent, previousState, userInfo) -> RepositioningMachineState? in
                
                guard let event = givenEvent else { return nil }
                var futurState: RepositioningMachineState? = nil
                
                switch (event, previousState) {
                    case (.start(let position, let positioningType), .initial):
                        switch (positioningType, position.positionStatus) {
                        case (.reposition, .inboxInside):
                            futurState = .needAffine(type: .manual, position: position)
                        case (.reposition, .inboxUnknown):
                            futurState = .needInfos(type: (position.threshold == .good) ? .outdoor : .indoor, position: position)
                        case (.reposition, .outbox):
                            futurState = .final(position: position, mode: .userFixed)
                        case (.reposition, .inboxOutside):
                            futurState = nil
                        case (.routing, .outbox):
                            futurState = .final(position: position, mode: .userFixed)
                        case (.routing, .inboxInside):
                            futurState = .final(position: position, mode: .userFixed)
                        case (.routing, .inboxOutside):
                            futurState = .final(position: position, mode: .userFixed)
                        case (.routing, .inboxUnknown):
                            futurState = .needInfos(type: (position.threshold == .good) ? .outdoor : .indoor, position: position)
                        }

                    case (.moreInfos(let type, let decision), .needInfos(_, let position)):
                        switch (type, decision) {
                            case (.indoor, true):
                                futurState = .needAffine(type: .manual, position: position)
                            case (.indoor, false):
                                futurState = .final(position: position.with(positionStatus: .inboxOutside), mode: .degraded)
                            case (.outdoor, true):
                                futurState = .final(position: position.with(positionStatus: .inboxOutside), mode: .userFixed)
                            case (.outdoor, false):
                                futurState = .needAffine(type: .assisted, position: position)
                        }
                    
                    
                    case (.locationAffined(_, let newPosition), .needAffine):
                        futurState = .projected(position: newPosition.projected)
                    case (.locationAffined(_, let newPosition), .projected):
                        futurState = .projected(position: newPosition.projected)
                    case (.confirm, .projected(let position)):
                        futurState = .final(position: position, mode: .userFixed)
                    case (.force(let forcedPosition), _):
                        futurState = .final(position: forcedPosition, mode: .forced)
                    default:
                        futurState = nil
                }
                return futurState
                
            })
            
        })
        
        
        machine.addHandler(event: .any, handler: { [weak self] context in
            
            
            let functionName: String = "didChangeState"
            
            print("[\(functionName)] -- from \(context.fromState.description) to \(context.toState.description)")
            
            
            switch context.toState {
                case .initial:
                    print("Here we start")
                case .needInfos(let type,_):
                    self?.delegate?.positionHelperAskFor(help: type)
                case .needAffine(let type, let userPosition):
                    self?.delegate?.positionHelperAskFor(userRepositioning: type, userPosition: userPosition)
                case .projected(let userPosition):
                    self?.delegate?.positionHelperNotify(userPosition: userPosition)
                case .final(let userPosition, let mode):
                    self?.delegate?.positionHelperNotify(routingPrecision: mode, userPosition: userPosition)
                case .aborted:
                    print("[\(functionName)]")
            }
            
        })
 
    }
    
}

extension RepositioningManager: Loggable {
    var domain: Logger.Domain {
        return Logger.Domain.custom("StateMachine")
    }
    
    
}

extension RepositioningManager: RepositioningManagerInstance {

    var systemDelegate: PositionHelperInternalDelegate? {
        get {
            return self.delegate
        }
        set {
            self.delegate = systemDelegate
        }
    }
    
    func userAskFor(type: RepositioningType, with userPosition: UserPosition) {
        self.machine.tryEvent(.start(position: userPosition, type: type))
    }
    
    func userRespondsTo(help type: PositionHelperNeedHelpType, with decision: Bool) {
        self.machine.tryEvent(.moreInfos(type: type, value: decision))
    }
    
    func userRespondsTo(userRepositioning type: PositionHelperRepositioningType, with correctedPosition: UserPosition) {
        self.machine.tryEvent(.locationAffined(type: type, position: correctedPosition))
    }
    
    func userConfirms(hisPosition: UserPosition) {
        self.machine.tryEvent(.confirm(position: hisPosition))
    }
    
    
}
