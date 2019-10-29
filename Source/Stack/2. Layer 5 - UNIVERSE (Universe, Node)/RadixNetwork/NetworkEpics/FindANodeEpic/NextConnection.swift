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

final class NextConnection {
    private let radixPeerSelector: RadixPeerSelector
    private let shardsMatcher: ShardsMatcher
    private let maxSimultaneousConnectionRequests: Int
    private let determineIfMoreInfoIsNeeded: DetermineIfMoreInfoIsNeeded
    
    internal init(
        radixPeerSelector: RadixPeerSelector = .default,
        shardsMatcher: ShardsMatcher = .default,
        maxSimultaneousConnectionRequests: Int = FindANodeEpic.maxSimultaneousConnectionRequests,
        determineIfMoreInfoIsNeeded: DetermineIfMoreInfoIsNeeded = .ifShardSpaceIsUnknown
    ) {
        self.radixPeerSelector = radixPeerSelector
        self.shardsMatcher = shardsMatcher
        self.maxSimultaneousConnectionRequests = maxSimultaneousConnectionRequests
        self.determineIfMoreInfoIsNeeded = determineIfMoreInfoIsNeeded
    }
    
}

// MARK: - DetermineIfMoreInfoIsNeeded
extension NextConnection {
    struct DetermineIfMoreInfoIsNeeded {
        typealias Filter = (RadixNodeState) -> Bool
        private let _filter: Filter
        init(filter: @escaping Filter) {
            self._filter = filter
        }
    }
}

extension NextConnection.DetermineIfMoreInfoIsNeeded {
    
    func moreInfoIsNeeded(for nodes: [RadixNodeState]) -> [RadixNodeState] {
        return nodes.filter(_filter)
    }
    
}
extension NextConnection.DetermineIfMoreInfoIsNeeded {
    static var ifShardSpaceIsUnknown: Self {
        return Self {
            $0.shardSpace == nil
        }
    }
}

extension NextConnection {
    func nextConnection(shards: Shards, networkState: RadixNetworkState) -> [NodeAction] {
        
        func discoverMore() -> [NodeAction] {
            let discoverMore: DiscoverMoreNodesAction = .init()
            return [discoverMore]
        }
        
        func nodesWithWebSocketStatus(_ websocketStatus: WebSocketStatus) -> [RadixNodeState] {
            networkState.nodesWithWebsocketStatus(websocketStatus)//.map { $0.node }
        }
        
        guard nodesWithWebSocketStatus(.connecting).count < maxSimultaneousConnectionRequests else {
            return []
        }
        
        let disconnectedPeers = nodesWithWebSocketStatus(.disconnected)
        if disconnectedPeers.isEmpty {
            return discoverMore()
        }
        
        let correctShardNodes = disconnectedPeers
            .filter { nodeState in
                guard let shardSpace = nodeState.shardSpace else { return false }
                return shardsMatcher.does(shardSpace: shardSpace, intersectWithShards: shards)
        }
        
        if let correctShardNodesSet = try? NonEmptySet(array: correctShardNodes.map { $0.node }) {
            let selectedNode = self.radixPeerSelector.selectPeer(correctShardNodesSet)
            return [ConnectWebSocketAction(node: selectedNode)]
        } else {
            
            let moreInfoIsNeededForThese = determineIfMoreInfoIsNeeded.moreInfoIsNeeded(for: disconnectedPeers)
            if moreInfoIsNeededForThese.isEmpty {
                return discoverMore()
            }
            
            return moreInfoIsNeededForThese.map { $0.node }
                .flatMap { node -> [NodeAction] in
                    [
                        GetNodeInfoActionRequest(node: node),
                        GetUniverseConfigActionRequest(node: node)
                    ]
            }
        }
    }
}
