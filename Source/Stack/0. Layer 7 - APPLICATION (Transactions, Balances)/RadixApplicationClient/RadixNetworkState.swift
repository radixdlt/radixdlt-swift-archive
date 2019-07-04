//
//  NetworkState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Current state of nodes connected to
public struct RadixNetworkState: Equatable, CustomDebugStringConvertible {
    public let nodes: [Node: RadixNodeState]

    public init(nodes: [Node: RadixNodeState] = [:]) {
        self.nodes = nodes
    }
}

public extension RadixNetworkState {
    init(node: Node, state: RadixNodeState) {
        self.init(nodes: [node: state])
    }
}

// MARK: - CustomDebugStringConvertible
public extension RadixNetworkState {
    var debugDescription: String {
        let mapDescription = nodes.map {
            "\($0.key.debugDescription): \($0.value.debugDescriptionIncludeNode(false))"
        }.joined(separator: ", ")
        
        return """
            RadixNetworkState(\(mapDescription))
        """
    }
}
