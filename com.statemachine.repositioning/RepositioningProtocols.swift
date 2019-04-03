//
//  RepositioningProtocols.swift
//  com.statemachine.repositioning
//
//  Created by Julien Goudet on 02/04/2019.
//  Copyright © 2019 Hootcode. All rights reserved.
//

import Foundation

/// **From App to SDK(system)**
///
/// Give informations thanks to user interaction
/// Called by the app, when user interacts about routing or location stuff
///
/// `[App].call(sdkSystemDatasource.function(params))`
protocol PositionHelperDatasource: class {
    
    /// Call this datasourced-function when a routing or a re-position is asked by the user
    ///
    /// **Step 1**
    func userAskFor(type: RepositioningType)
    
    /// Call this datasourced-function the user reply to the given decisional popup
    ///
    /// **Step 5**
    func userRespondsTo(help type: PositionHelperNeedHelpType, with decision: Bool)
    
    /// Call this datasourced-function when the user finally end the repositioning
    ///
    /// **Step 9**
    func userRespondsTo(userRepositioning type: PositionHelperRepositioningType, with correctedPosition: UserPosition)
}


/// **From SDK(system) to SDK(RoutingHelper)**
///
/// give information thanks to user interaction
/// Called by the SDK system class, when client ask for it
///
/// `[SDK.system].callInternally(sdkInternalDatasource.method(params))`
protocol PositionHelperInternalDatasource: class {
    
    /// Hatch-like function, [App -> this -> InternalHelper]
    /// Just adding last user position to the function
    ///
    /// **Step 2**
    ///
    /// - SeeAlso: PositionHelperDatasource.userAskFor(type: ActionType)
    func userAskFor(type: RepositioningType, with userPosition: UserPosition)
    
    /// Hatch-like function, [App -> this -> InternalHelper]
    ///
    /// **Step 6**
    ///
    /// - SeeAlso: PositionHelperDatasource.userRespondsTo(help type: PositionHelperNeedHelpType, with decision: Bool)
    func userRespondsTo(help type: PositionHelperNeedHelpType, with decision: Bool)
    
    /// Hatch-like function, [App -> this -> InternalHelper]
    ///
    /// **Step 10**
    ///
    /// - SeeAlso: PositionHelperDatasource.userRespondsTo(userRepositioning type: PositionHelperRepositioningType, with correctedPosition: UserPosition)
    func userRespondsTo(userRepositioning type: PositionHelperRepositioningType, with correctedPosition: UserPosition)
    
    
    func userConfirms(hisPosition: UserPosition)
    
    
    
}


/// **From SDK(routingHelper) to SDK(system)**
///
/// Notify the app that logic need information or give the result before launch a routing
/// Implemented in SDK System class, which relay this to the client
///
/// `[SDK.positionhelper].callInternally(sdkInternalDelegate.method(params))`
protocol PositionHelperInternalDelegate: class {
    
    /// Internally call this delegated-function when a rethorical choice must be asked to the user to refine (re)position logic
    /// ex: Are you inside of the building ? / we detect your position outside; is it correct ?
    ///
    /// **Step 3**
    func positionHelperAskFor(help type: PositionHelperNeedHelpType)
    
    /// Internally call this delegated-function when a reposition must be done, thanks to the user help
    /// * Two choices:
    ///     * manual - the user must return us position x,y,z
    ///     * assisted - we know x,y the user must return us z (floor)
    ///
    /// **Step 7**
    func positionHelperAskFor(userRepositioning type: PositionHelperRepositioningType, userPosition: UserPosition)
    
    
    func positionHelperNotify(userPosition projected: UserPosition)
    
    /// Internally call this delegated-function when the user can finally do his routing request
    /// * Two precision types:
    ///     * userFixed - we know the precise location, all is good for routing
    ///     * assumed - we are not sure about the given user location, routing can be done but we must tell the user the result can be wrong
    ///
    /// **Step 11**
    func positionHelperNotify(routingPrecision type: PositionHelperRoutingPrecisionType, userPosition: UserPosition)
}


/// **From SDK(system) to App**
///
/// Notify the app that logic need information or give the result before launch a routing
/// Implemented in SDK System class, which relay this to the client
///
/// `[SDK.system].call(delegate.method(params))`
protocol PositionHelperDelegate: class {
    
    /// Hatch-like function, [InternalHelper -> this -> App]
    ///
    /// **Step 4**
    ///
    /// - SeeAlso: PositionHelperInternalDelegate.positionHelperAskFor(help type: PositionHelperNeedHelpType)
    func positionHelperAskFor(help type: PositionHelperNeedHelpType)
    
    /// Hatch-like function, [InternalHelper -> this -> App]
    ///
    /// **Step 8**
    ///
    /// - SeeAlso: PositionHelperInternalDelegate.positionHelperAskFor(userRepositioning type: PositionHelperRepositioningType)
    func positionHelperAskFor(userRepositioning type: PositionHelperRepositioningType)
    
    /// Hatch-like function, [InternalHelper -> this -> App]
    ///
    /// **Step 12**
    ///
    /// - SeeAlso: PositionHelperInternalDelegate.positionHelperNotify(routingPrecision type: PositionHelperRoutingPrecisionType)
    func positionHelperNotify(routingPrecision type: PositionHelperRoutingPrecisionType)
}
