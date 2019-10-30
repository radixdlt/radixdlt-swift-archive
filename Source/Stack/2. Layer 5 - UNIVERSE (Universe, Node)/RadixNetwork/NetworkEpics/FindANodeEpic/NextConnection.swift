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
    private let determineIfPeerIsSuitable: DetermineIfPeerIsSuitable
    private let maxSimultaneousConnectionRequests: Int
    private let determineIfMoreInfoIsNeeded: DetermineIfMoreInfoIsNeeded
    
    internal init(
        radixPeerSelector: RadixPeerSelector = .default,
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable = .default,
        maxSimultaneousConnectionRequests: Int = FindANodeEpic.maxSimultaneousConnectionRequests,
        determineIfMoreInfoIsNeeded: DetermineIfMoreInfoIsNeeded = .default
    ) {
        self.radixPeerSelector = radixPeerSelector
        self.determineIfPeerIsSuitable = determineIfPeerIsSuitable
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
    
    static let `default`: Self = .ifShardSpaceIsUnknown
}

extension NextConnection {
    func nextConnection(shards: Shards, networkState: RadixNetworkState) -> [NodeAction] {
        
        func discoverMore() -> [NodeAction] { [DiscoverMoreNodesAction()] }
        
        func nodesWithWebSocketStatus(_ webSocketStatus: WebSocketStatus) -> [RadixNodeState] {
            networkState.nodesWithWebsocketStatus(webSocketStatus)
        }
        
        guard nodesWithWebSocketStatus(.connecting).count < maxSimultaneousConnectionRequests else {
            // Max pending connections => await, do nothing for now
            return []
        }
        
        // We only care about nodes with ws status `.disconnected`, because these are the nodes we know of, that we potentially might wanna connect to (if suitable), otherwise we need to find more candidates
        let candidateNodes = nodesWithWebSocketStatus(.disconnected)
        
        if candidateNodes.isEmpty {
            return discoverMore()
        }
        
        let correctShardNodes = candidateNodes.filter {
            determineIfPeerIsSuitable.isPeer(withState: $0, suitableBasedOnShards: shards)
        }
        
        if let correctShardNodesSet = try? NonEmptySet(array: correctShardNodes.map { $0.node }) {
            let selectedNode = self.radixPeerSelector.selectPeer(correctShardNodesSet)
            return [ConnectWebSocketAction(node: selectedNode)]
        } else {
            
            let moreInfoIsNeededForThese = determineIfMoreInfoIsNeeded.moreInfoIsNeeded(for: candidateNodes)
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
