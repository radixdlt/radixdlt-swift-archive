//
//  RadixNetwork.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol RadixNetwork {
    var state: RadixNetworkState { get }
    func reduce(state: RadixNetworkState, action: NodeAction) -> RadixNetworkState
}

public final class DefaultRadixNetwork: RadixNetwork {
    public private(set) var state: RadixNetworkState
    
    public init(state: RadixNetworkState = .init()) {
        self.state = state
    }
}

public extension DefaultRadixNetwork {
    
    func reduce(state: RadixNetworkState, action: NodeAction) -> RadixNetworkState {
        // TODO implement me
        return state
    }
}
