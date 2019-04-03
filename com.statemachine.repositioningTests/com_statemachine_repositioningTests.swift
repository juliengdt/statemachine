//
//  com_statemachine_repositioningTests.swift
//  com.statemachine.repositioningTests
//
//  Created by Julien Goudet on 02/04/2019.
//  Copyright © 2019 Hootcode. All rights reserved.
//

import XCTest
import CoreLocation
@testable import com_statemachine_repositioning

class com_statemachine_repositioningTests: XCTestCase {
    
    private let indoorLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private let outdoorLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    private var manager: RepositioningManager!

    override func setUp() {
        manager = RepositioningManager()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: - Initalization

    func testStateMachineWellInitialized() {
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.initial)
    }
    
    //MARK: - Simple reposition

    func testRepositioningWhenOutbox() {
        
        let outdoorUserPosition = UserPosition(coordinate: self.outdoorLocation ,
                                               threshold: ThresholdType.good,
                                               floor: nil,
                                               positionStatus: PositionStatus.outbox)
        let mode = RepositioningType.reposition
        
        XCTAssertEqual(mode, RepositioningType.reposition)
        XCTAssertEqual(outdoorUserPosition.positionStatus, PositionStatus.outbox)
        
        manager.userAskFor(type: mode, with: outdoorUserPosition)
        
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.final(position: outdoorUserPosition,
                                                                              mode: PositionHelperRoutingPrecisionType.userFixed))
        
    }
    
    
    func testRepositioningWhenInboxOutdoor() {
        
        let outdoorUserPosition = UserPosition(coordinate: self.outdoorLocation ,
                                               threshold: ThresholdType.good,
                                               floor: nil,
                                               positionStatus: PositionStatus.inboxOutside)
        let mode = RepositioningType.reposition
        
        XCTAssertEqual(mode, RepositioningType.reposition)
        XCTAssertEqual(outdoorUserPosition.positionStatus, PositionStatus.inboxOutside)
        
        manager.userAskFor(type: mode, with: outdoorUserPosition)
        
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.initial)
        
    }
    
    func testRepositioningWhenInboxUnknownWithGoodGPS() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                               threshold: ThresholdType.good,
                                               floor: nil,
                                               positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.reposition
        
        XCTAssertEqual(mode, RepositioningType.reposition)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: PositionHelperNeedHelpType.outdoor, position: indoorUserPosition))
        
    }
    
    func testRepositioningWhenInboxUnknownWithBadGPS() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.bad,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.reposition
        
        XCTAssertEqual(mode, RepositioningType.reposition)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: PositionHelperNeedHelpType.indoor, position: indoorUserPosition))
        
    }
    
    func testRepositioningWhenInboxIndoor() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.bad,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxInside)
        let mode = RepositioningType.reposition
        
        XCTAssertEqual(mode, RepositioningType.reposition)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxInside)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needAffine(type: PositionHelperRepositioningType.manual, position: indoorUserPosition))

    }

    
    //MARK: - Simple Routing
    
    /// When i'm outside of the box and want a route, then use directly my position
    func testRoutingWhenOutBox() {
        
        
        let outdoorUserPosition = UserPosition(coordinate: self.outdoorLocation ,
                                               threshold: ThresholdType.good,
                                               floor: nil,
                                               positionStatus: PositionStatus.outbox)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(outdoorUserPosition.positionStatus, PositionStatus.outbox)
        
        manager.userAskFor(type: mode, with: outdoorUserPosition)
        
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.final(position: outdoorUserPosition,
                                                                              mode: PositionHelperRoutingPrecisionType.userFixed))
        
    }
    
    
    //MARK: - Complex Routing -- Good GPS
    
    func testRoutingWhenInboxWithGoodGPS() {
       
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.good,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: PositionHelperNeedHelpType.outdoor, position: indoorUserPosition))
        
    }
    
    func testRoutingWhenInboxWithGoodGPSThenUserSaysIndoor() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.good,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        let expectedHelpType = PositionHelperNeedHelpType.outdoor
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: expectedHelpType, position: indoorUserPosition))
        
        manager.userRespondsTo(help: expectedHelpType, with: false)
        let expectedRepositioningType = PositionHelperRepositioningType.assisted
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needAffine(type: expectedRepositioningType, position: indoorUserPosition))
        
    }
    
    func testRoutingWhenInboxWithGoodGPSThenUserSaysIndoorThenSendsHisPosition() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.good,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        let expectedHelpType = PositionHelperNeedHelpType.outdoor
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: expectedHelpType, position: indoorUserPosition))
        
        manager.userRespondsTo(help: expectedHelpType, with: false)
        let expectedRepositioningType = PositionHelperRepositioningType.assisted
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needAffine(type: expectedRepositioningType, position: indoorUserPosition))
        
        let indoorPositionWithFloorSettedToFirst = indoorUserPosition.with(floor: 1)
        manager.userRespondsTo(userRepositioning: expectedRepositioningType, with: indoorPositionWithFloorSettedToFirst)
        // lack -> projection
        let projectedPosition = indoorPositionWithFloorSettedToFirst
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.projected(position: projectedPosition))

        
    }
    
    func testRoutingWhenInboxWithGoodGPSThenUserSaysIndoorThenSendsHisPositionThenReSend() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.good,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        let expectedHelpType = PositionHelperNeedHelpType.outdoor
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: expectedHelpType, position: indoorUserPosition))
        
        manager.userRespondsTo(help: expectedHelpType, with: false)
        let expectedRepositioningType = PositionHelperRepositioningType.assisted
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needAffine(type: expectedRepositioningType, position: indoorUserPosition))
        
        let indoorPositionWithFloorSettedToFirst = indoorUserPosition.with(floor: 1)
        manager.userRespondsTo(userRepositioning: expectedRepositioningType, with: indoorPositionWithFloorSettedToFirst)
        // lack -> projection
        let projectedPosition = indoorPositionWithFloorSettedToFirst
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.projected(position: projectedPosition))
        
        
        let indoorPositionWithFloorSettedToFourth = projectedPosition.with(floor: 4)
        manager.userRespondsTo(userRepositioning: expectedRepositioningType, with: indoorPositionWithFloorSettedToFourth)
        // lack -> projection
        let projectedPositionAgain = indoorPositionWithFloorSettedToFourth
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.projected(position: projectedPositionAgain))
        
    }
    
    func testRoutingWhenInboxWithGoodGPSThenUserSaysIndoorThenSendsHisPositionThenConfirm() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.good,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        let expectedHelpType = PositionHelperNeedHelpType.outdoor
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: expectedHelpType, position: indoorUserPosition))
        
        manager.userRespondsTo(help: expectedHelpType, with: false)
        let expectedRepositioningType = PositionHelperRepositioningType.assisted
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needAffine(type: expectedRepositioningType, position: indoorUserPosition))
        
        let indoorPositionWithFloorSettedToFirst = indoorUserPosition.with(floor: 1)
        manager.userRespondsTo(userRepositioning: expectedRepositioningType, with: indoorPositionWithFloorSettedToFirst)
        // lack -> projection
        let projectedPosition = indoorPositionWithFloorSettedToFirst
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.projected(position: projectedPosition))
        
        manager.userConfirms(hisPosition: projectedPosition)
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.final(position: projectedPosition,
                                                                              mode: PositionHelperRoutingPrecisionType.userFixed))
        
    }
    
    func testRoutingWhenInboxWithGoodGPSThenUserSaysOutdoor() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.good,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        let expectedHelpType = PositionHelperNeedHelpType.outdoor
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: expectedHelpType, position: indoorUserPosition))
        
        let expectedPositionStatus = PositionStatus.inboxOutside
        manager.userRespondsTo(help: expectedHelpType, with: true)
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.final(position: indoorUserPosition.with(positionStatus: expectedPositionStatus),
                                                                              mode: PositionHelperRoutingPrecisionType.userFixed))
    }
    


    //MARK: - Complex Routing -- Bad GPS
    
    func testRoutingWhenInboxWithBadGPS() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.bad,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: PositionHelperNeedHelpType.indoor, position: indoorUserPosition))
        
    }
    
    
    func testRoutingWhenInboxWithBadGPSThenUserSaysIndoor() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.bad,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        let expectedHelpType = PositionHelperNeedHelpType.indoor
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: expectedHelpType, position: indoorUserPosition))
        
        manager.userRespondsTo(help: expectedHelpType, with: true)
        let expectedRepositioningType = PositionHelperRepositioningType.manual
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needAffine(type: expectedRepositioningType, position: indoorUserPosition))

    }
    
    func testRoutingWhenInboxWithBadGPSThenUserSaysIndoorThenConfirm() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.bad,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        let expectedHelpType = PositionHelperNeedHelpType.indoor
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: expectedHelpType, position: indoorUserPosition))
        
        manager.userRespondsTo(help: expectedHelpType, with: true)
        let expectedRepositioningType = PositionHelperRepositioningType.manual
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needAffine(type: expectedRepositioningType, position: indoorUserPosition))
        
        let manualIndoorPosition = UserPosition(coordinate: CLLocationCoordinate2D(latitude: 18.0, longitude: 40.0),
                                                                threshold: ThresholdType.good,
                                                                floor: 0,
                                                                positionStatus: PositionStatus.inboxInside)
        
        manager.userRespondsTo(userRepositioning: expectedRepositioningType, with: manualIndoorPosition)
        // lack -> projection
        let projectedPosition = manualIndoorPosition
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.projected(position: projectedPosition))
        
        manager.userConfirms(hisPosition: projectedPosition)
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.final(position: projectedPosition,
                                                                              mode: PositionHelperRoutingPrecisionType.userFixed))
        
    }
    
    
    
    func testRoutingWhenInboxWithBadGPSThenUserSaysOutdoor() {
        
        let indoorUserPosition = UserPosition(coordinate: self.indoorLocation ,
                                              threshold: ThresholdType.bad,
                                              floor: nil,
                                              positionStatus: PositionStatus.inboxUnknown)
        let mode = RepositioningType.routing
        
        XCTAssertEqual(mode, RepositioningType.routing)
        XCTAssertEqual(indoorUserPosition.positionStatus, PositionStatus.inboxUnknown)
        
        manager.userAskFor(type: mode, with: indoorUserPosition)
        let expectedHelpType = PositionHelperNeedHelpType.indoor
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.needInfos(type: expectedHelpType, position: indoorUserPosition))
        
        manager.userRespondsTo(help: expectedHelpType, with: false)
        let expectedPositionStatus = PositionStatus.inboxOutside
        let expectedPrecisionType = PositionHelperRoutingPrecisionType.degraded
        XCTAssertEqual(manager.machine.state, RepositioningMachineState.final(position: indoorUserPosition.with(positionStatus: expectedPositionStatus),
                                                                              mode: expectedPrecisionType))
        
    }
    

}
