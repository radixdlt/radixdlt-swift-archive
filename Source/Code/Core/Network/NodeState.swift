//
//  NodeState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// TODO add websocket library StarScream
public typealias WebSocketStatus = Void

public struct NodeState {
    public let node: Node
    public let status: WebSocketStatus
    public let nodeRunnerData: NodeRunnerData
    public let version: Int
    public let universeConfig: UniverseConfig
}
