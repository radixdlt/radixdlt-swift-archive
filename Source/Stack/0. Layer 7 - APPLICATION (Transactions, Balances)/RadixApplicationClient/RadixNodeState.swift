//
//  RadixNodeState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Immutable state at a certain point in time of a RadixNode (`Node`)
public struct RadixNodeState: Equatable {
    public let node: Node
    public let websocketStatus: WebSocketStatus
    public let universeConfig: UniverseConfig?
    public let nodeInfo: NodeInfo?
    
    public init(node: Node, webSocketStatus: WebSocketStatus, nodeInfo: NodeInfo? = nil, universeConfig: UniverseConfig? = nil) {
        self.node = node
        self.websocketStatus = webSocketStatus
        self.nodeInfo = nodeInfo
        self.universeConfig = universeConfig
    }
}

public extension RadixNodeState {
   
    var shardSpace: ShardSpace? {
        guard let nodeInfo = nodeInfo else { return nil }
        return nodeInfo.shardSpace
    }
    
//    static func == (lhs: RadixNodeState, rhs: RadixNodeState) -> Bool {
//        return lhs.node == rhs.node && lhs.universeConfig == rhs.universeConfig
//    }
}

