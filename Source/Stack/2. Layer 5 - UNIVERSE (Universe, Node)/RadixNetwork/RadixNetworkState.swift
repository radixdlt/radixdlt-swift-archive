//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

/// Current state of nodes connected to
public struct RadixNetworkState: ExpressibleByDictionaryLiteral, ExpressibleByArrayLiteral, Equatable, CustomDebugStringConvertible {
    
    let nodes: [Node: RadixNodeState]
    public init(nodes: [Node: RadixNodeState] = [:]) {
        self.nodes = nodes
    }
}

public extension RadixNetworkState {
    
    typealias Key = Node
    typealias Value = RadixNodeState
    typealias Element = RadixNodeState
    
    init(arrayLiteral nodeStates: RadixNodeState...) {
        self.nodes = [Key: Value](uniqueKeysWithValues: nodeStates.map { ($0.node, $0) })
    }
        
    init(keyValuePairs nodes: KeyValuePairs<Key, Value>) {
        self.nodes = [Key: Value](uniqueKeysWithValues: nodes.map { ($0.key, $0.value) })
    }
    
    init(dictionaryLiteral nodes: (Key, Value)...) {
        self.nodes = [Key: Value](uniqueKeysWithValues: nodes)
    }
}

public extension RadixNetworkState {
    subscript(node: Key) -> Value? { nodes[node] }
}

internal extension RadixNetworkState {
    func insertingMergeIfNeeded(
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

public extension RadixNetworkState {
    var readyNodes: [RadixNodeState] {
//        nodes.filter { $0.value.websocketStatus == .ready }.map { $0.value }
        nodesWithWebsocketStatus(.ready)
    }
    
    var unreadyNodes: [RadixNodeState] {
//        nodes.filter { $0.value.websocketStatus != .ready }.map { $0.value }
        nodesWithWebsocketStatus(.ready, !=)
    }
    
    func nodesWithWebsocketStatus(_ websocketStatus: WebSocketStatus, _ compare: (WebSocketStatus, WebSocketStatus) -> Bool = { $0 == $1 }) -> [RadixNodeState] {
        nodes.filter {
            compare($0.value.websocketStatus, websocketStatus)
        }.map { $0.value }
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

