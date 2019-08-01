//
//  RadixNodeState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Immutable state at a certain point in time of a RadixNode (`Node`)
public struct RadixNodeState: Equatable, CustomDebugStringConvertible {
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
    func debugDescriptionIncludeNode(_ includeNode: Bool) -> String {
        
        return """
        \(includeNode.ifTrue { "Node: \(node.debugDescription),\n" })
        webSocketStatus: \(websocketStatus),
        nodeInfo: \(nodeInfo.ifPresent(elseDefaultTo: "nil") { "\($0.shardSpace)" })
        universeConfig: \(universeConfig.ifPresent(elseDefaultTo: "nil") { "\($0)" }),
        """
    }
    
    var debugDescription: String {
        return debugDescriptionIncludeNode(true)
    }
}

public extension RadixNodeState {
   
    var shardSpace: ShardSpace? {
        guard let nodeInfo = nodeInfo else { return nil }
        return nodeInfo.shardSpace
    }
}

