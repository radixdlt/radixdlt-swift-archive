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

// swiftlint:disable colon opening_brace

/// Immutable state at a certain point in time of a RadixNode (`Node`)
public struct RadixNodeState:
    Equatable,
    CustomDebugStringConvertible,
    Identifiable
{
    // swiftlint:enable colon opening_brace
    public let node: Node
    public let webSocketStatus: WebSocketStatus
    public let universeConfig: UniverseConfig?
    public let nodeInfo: NodeInfo?
    
    public init(
        node: Node,
        webSocketStatus: WebSocketStatus,
        nodeInfo: NodeInfo? = nil,
        universeConfig: UniverseConfig? = nil
    ) {
        self.node = node
        self.webSocketStatus = webSocketStatus
        self.nodeInfo = nodeInfo
        self.universeConfig = universeConfig
    }
}

public extension RadixNodeState {
    func debugDescriptionIncludeNode(_ includeNode: Bool) -> String {
        
        return """
        \(includeNode.ifTrue { "\(node.debugDescription)" }), hasNodeInfo: \(nodeInfo != nil), hasUniverseConfig: \(universeConfig != nil), webSocketStatus: \(webSocketStatus)
        """
    }
    
    var debugDescription: String {
        return debugDescriptionIncludeNode(true)
    }
}

// MARK: Identifiable
public extension RadixNodeState {
    var id: Node.ID { node.id }
}

public extension RadixNodeState {
   
    var shardSpace: ShardSpace? {
        guard let nodeInfo = nodeInfo else { return nil }
        return nodeInfo.shardSpace
    }
}

internal extension RadixNodeState {
    func merging(
        webSocketStatus newWSStatus: WebSocketStatus,
        nodeInfo newNodeInfo: NodeInfo? = nil,
        universeConfig newUniverseConfig: UniverseConfig? = nil
    ) -> RadixNodeState {
        
        return RadixNodeState(
            node: node,
            webSocketStatus: newWSStatus,
            nodeInfo: newNodeInfo ?? self.nodeInfo,
            universeConfig: newUniverseConfig ?? self.universeConfig
        )
    }
}
