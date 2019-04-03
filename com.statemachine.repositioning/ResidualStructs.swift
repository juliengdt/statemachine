//
//  ResidualStructs.swift
//  com.statemachine.repositioning
//
//  Created by Julien Goudet on 02/04/2019.
//  Copyright © 2019 Hootcode. All rights reserved.
//

import Foundation
import CoreLocation

/* Residual code */

enum ThresholdType: Int {
    case good
    case bad
}


enum PositionStatus: Int {
    case outbox
    case inboxUnknown
    case inboxOutside
    case inboxInside
}


struct UserPosition: Equatable, Hashable {
    
    let coordinate: CLLocationCoordinate2D
    let threshold: ThresholdType
    let floor: Int?
    let positionStatus: PositionStatus
    
    
    func with(positionStatus new: PositionStatus) -> UserPosition {
        return UserPosition(coordinate: self.coordinate,
                            threshold: self.threshold,
                            floor: self.floor,
                            positionStatus: new)
    }
    
    func with(floor new: Int) -> UserPosition {
        return UserPosition(coordinate: self.coordinate,
                            threshold: self.threshold,
                            floor: new,
                            positionStatus: self.positionStatus)
    }
    
    
    var projected: UserPosition {
        return self
    }
    
    static func == (lhs: UserPosition, rhs: UserPosition) -> Bool {
        return ((lhs.coordinate == rhs.coordinate) &&
            (lhs.threshold == rhs.threshold) &&
            (lhs.positionStatus == rhs.positionStatus) &&
            (lhs.floor == rhs.floor))
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.coordinate)
        hasher.combine(self.threshold.rawValue)
        if let _floor = self.floor {
            hasher.combine(_floor)
        }
        hasher.combine(self.positionStatus.rawValue)
        
    }
    
}

extension CLLocationCoordinate2D: Equatable, Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude) && (lhs.longitude == rhs.longitude)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.longitude)
        hasher.combine(self.latitude)
    }
    
}

enum PositionHelperRepositioningType: Int {
    // I know the position, just need the floor
    case assisted
    // I don't know anything
    case manual
}

enum PositionHelperRoutingPrecisionType: Int {
    case userFixed
    case degraded
    case forced
}


enum PositionHelperNeedHelpType: Int {
    case indoor
    case outdoor
}

enum RepositioningType: Int {
    case reposition
    case routing
}
