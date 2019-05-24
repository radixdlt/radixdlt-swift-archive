//
//  TokenDefintionState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ApplicationState {}

/// The state and data of a token at a given moment in time
public struct TokenState {}

public struct TokenDefintionState: ApplicationState, DictionaryConvertible {
    public typealias Key = ResourceIdentifier
    public typealias Value = TokenState
    
    public let state: Map
    
    init(state: Map) {
        self.state = state
    }
}

// MARK: - DictionaryConvertible
public extension TokenDefintionState {
    var dictionary: Map { return state }
    init(dictionary state: Map) {
        self.init(state: state)
    }
}
