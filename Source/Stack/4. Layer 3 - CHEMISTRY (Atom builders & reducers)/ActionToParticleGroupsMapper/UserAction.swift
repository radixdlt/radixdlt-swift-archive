//
//  UserAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum UserActionName: String, Hashable {
    
    // Stateful actions
    case transferTokens
    case burnTokens
    case mintTokens
    
    // Stateless actions
    case createToken
    case putUnique
    case sendMessage
}

public protocol UserAction {
    var nameOfAction: UserActionName { get }
}
