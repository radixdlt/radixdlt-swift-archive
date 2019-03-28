//
//  NodeState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct NodeState: Equatable {
    public let node: Node
    public let status: WebSocketStatus
    public let nodeRunnerData: NodeRunnerData?
    public let version: Int?
    public let universeConfig: UniverseConfig?
    
    public init(
        for node: Node,
        status: WebSocketStatus = .connected,
        nodeRunnerData: NodeRunnerData? = nil,
        version: Int? = nil,
        universeConfig: UniverseConfig? = nil) {
        self.node = node
        self.status = status
        self.nodeRunnerData = nodeRunnerData
        self.version = version
        self.universeConfig = universeConfig
    }
}
