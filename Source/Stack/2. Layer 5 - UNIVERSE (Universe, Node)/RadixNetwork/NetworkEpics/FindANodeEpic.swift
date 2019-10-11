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
import Combine

/// A Radix Network epic that is responsible for finding and connecting to suitable nodes.
///
/// Listens to the following `NodeAction`'s:
/// `FindANodeRequestAction`
///
/// outputs the following actions:
/// `DiscoverMoreNodesAction`,
/// `GetNodeInfoActionRequest`,
/// `GetUniverseConfigActionRequest`,
/// `ConnectWebSocketAction`
///
public final class FindANodeEpic: RadixNetworkEpic {
    public typealias PeerSelector = (NonEmptySet<Node>) -> Node
    private let peerSelector: PeerSelector
    
    init(
        peerSelector: @escaping PeerSelector = { $0.randomElement() }
    ) {
        self.peerSelector = peerSelector
    }
}

public enum FindANodeError: Swift.Error {
    case none
}

public extension FindANodeEpic {
 
    typealias Error = FindANodeError
    
    func epic(
        actions: AnyPublisher<NodeAction, Never>,
        networkState: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, FindANodeError> {
//        return actions.compactMap { $0 as? FindANodeRequestAction }.cat
        combineMigrationInProgress()
    }
}

private func getConnectedNodes(shards: Shards, state: RadixNetworkState) -> [Node] {
    return state.nodes
        .filter { $0.value.websocketStatus == .ready }
        .filter { $0.value.shardSpace?.intersectsWithShards(shards) ?? false }
        .map {
            return $0.key
            
        }
    
}
