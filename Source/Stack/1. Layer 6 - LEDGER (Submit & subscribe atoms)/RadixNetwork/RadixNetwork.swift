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

public protocol RadixNetworkNodeAction: NodeAction {
    var node: Node { get }
}

public extension DefaultRadixNetwork {
    
    func reduce(state: RadixNetworkState, action nodeAction: NodeAction) -> RadixNetworkState {
        guard let action = nodeAction as? RadixNetworkNodeAction else { return state }
        let node = action.node
        log.verbose("Reducing network, action: \(action), from state: \(state.debugDescription)")
        
        if let nodeInfoResult = action as? GetNodeInfoActionResult {
            return state.insertingMergeIfNeeded(for: node, nodeInfo: nodeInfoResult.result)
        } else if let universeConfigResult = action as? GetUniverseConfigActionResult {
            return state.insertingMergeIfNeeded(for: node, universeConfig: universeConfigResult.result)
        } else if let addNodeAction = action as? AddNodeAction {
            return state.insertingMergeIfNeeded(for: node, webSocketStatusValue: .new(.disconnected), nodeInfo: addNodeAction.nodeInfo)
        } else if let websocketEvent = action as? WebSocketEvent {
            return state.insertingMergeIfNeeded(for: node, webSocketStatusValue: .new(websocketEvent.webSocketStatus))
        } else {
            fatalError("missed something?")
        }
        
    }
}

extension RadixNodeState {
    fileprivate func merging(
        webSocketStatus newWSStatus: WebSocketStatus,
        nodeInfo newNodeInfo: NodeInfo? = nil,
        universeConfig newUniverseConfig: UniverseConfig? = nil
    ) -> RadixNodeState {
    
        return RadixNodeState.init(
            node: node,
            webSocketStatus: newWSStatus,
            nodeInfo: newNodeInfo ?? self.nodeInfo,
            universeConfig: newUniverseConfig ?? self.universeConfig
        )
    }
}

extension RadixNetworkState {
    fileprivate func insertingMergeIfNeeded(
        for node: Node,
        webSocketStatusValue: ExistingOrNewValue<WebSocketStatus> = .existingElseCrash,
        nodeInfo newNodeInfo: NodeInfo? = nil,
        universeConfig newUniverseConfig: UniverseConfig? = nil
    ) -> RadixNetworkState {
        
        let newNodeState: RadixNodeState
        let maybeCurrentState = nodes.valueFor(key: node)
        let newWSStatus = webSocketStatusValue.getValue(existing: maybeCurrentState?.websocketStatus)
        if let currentState = maybeCurrentState {
            newNodeState = currentState.merging(webSocketStatus: newWSStatus, nodeInfo: newNodeInfo, universeConfig: newUniverseConfig)
        } else {
            newNodeState = RadixNodeState(node: node, webSocketStatus: newWSStatus, nodeInfo: newNodeInfo, universeConfig: newUniverseConfig)
        }
        return RadixNetworkState(nodes: self.nodes.inserting(value: newNodeState, forKey: node))
    }
}

private enum ExistingOrNewValue<Value> {
    case existingElseCrash
    case new(Value)
}

extension ExistingOrNewValue {
    func getValue(existing: Value?) -> Value {
        switch self {
        case .existingElseCrash:
            guard let indeedExisting = existing else {
                incorrectImplementation("Bad logic")
            }
            return indeedExisting
        case .new(let new): return new
        }
    }
}
