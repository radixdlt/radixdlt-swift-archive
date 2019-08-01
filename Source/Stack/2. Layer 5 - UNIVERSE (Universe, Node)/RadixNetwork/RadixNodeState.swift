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

