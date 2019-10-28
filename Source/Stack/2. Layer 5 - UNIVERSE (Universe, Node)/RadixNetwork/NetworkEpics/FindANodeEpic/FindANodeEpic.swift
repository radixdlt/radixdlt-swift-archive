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

internal let void: Void = ()

// MARK: FindANodeEpic

/// A Radix Network epic that is responsible for finding and connecting to suitable nodes.
///
/// Listens to the following `NodeAction`'s:
/// `FindANodeRequestAction`
///
/// outputs the following actions:
/// `FindANodeResultAction`
/// `DiscoverMoreNodesAction`,
/// `GetNodeInfoActionRequest`,
/// `GetUniverseConfigActionRequest`,
/// `ConnectWebSocketAction`,
/// `CloseWebSocketAction`
///
public final class FindANodeEpic: RadixNetworkEpic {
    private let radixPeerSelector: RadixPeerSelector
    private let shardsMatcher: ShardsMatcher
    private let nodeCompatibilityChecker: NodeCompatibilityChecker
    
    init(
        radixPeerSelector: RadixPeerSelector = .random,
        shardsMatcher: ShardsMatcher = .default,
        nodeCompatibilityChecker: NodeCompatibilityChecker? = nil
    ) {
        
        self.radixPeerSelector = radixPeerSelector
        self.shardsMatcher = shardsMatcher
        self.nodeCompatibilityChecker = nodeCompatibilityChecker ?? NodeCompatibilityChecker.matchingShards(using: shardsMatcher)
    }
}

// MARK: Public
public extension FindANodeEpic {
    
    typealias Error = FindANodeError
    
    static let maxSimultaneousConnectionRequests = 2
}

public extension FindANodeEpic {
    
    // swiftlint:disable function_body_length
    
    /// This method identifies `NodeAction` which has been marked being dependent on some `RadixNode` (actions conforming to `FindANodeRequestAction`),
    /// e.g. `SubmitAtomActionRequest` (needs to find a _suitable_ node to submit the atom to) and is responsible for finding,
    /// and connecting to a suitable node, doing this by dispatching other potentially required `NodeAction`s to other Network Epics.
    func epic(
        actions actionsPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        return actionsPublisher
            .compactMap { $0 as? FindANodeRequestAction }^
            .flatMap { [unowned nodeCompatibilityChecker] findANodeRequestAction -> AnyPublisher<NodeAction, Never> in
                
                let shardsOfRequest = findANodeRequestAction.shards
                
                let connectedNodes: AnyPublisher<[Node], Never> = networkStatePublisher.map { networkState in
                    networkState.nodesWithWebsocketStatus(.ready)
                        .filter { nodeState in
                            nodeCompatibilityChecker.isCompatibleNode(nodeState: nodeState, shards: shardsOfRequest)
                    }.map { $0.node }
                    
                    }^
                    .debug { "1️⃣ connectedNodes: \($0)" }
                
                let selectedNode: AnyPublisher<NodeAction, Never> = connectedNodes
                    .compactMap { try? NonEmptySet<Node>(array: $0) }^
                    .map { [unowned self] in
                        print("🍐 select: \($0)")
                        return self.radixPeerSelector.selectPeer($0)
                    }^
                    .map { selectedNode in
                        FindANodeResultAction(node: selectedNode, request: findANodeRequestAction)
                    }^
                    .debug { "2️⃣ selectedNode: \($0)" }
                
                let findConnectionActions: AnyPublisher<NodeAction, Never> = connectedNodes
                    .filter { $0.isEmpty }^
                    .first()^
                    .ignoreOutput()^
                    .flatMap { _ in Empty<NodeAction, Never>() }
                    .append(
                        networkStatePublisher.map { networkState in
                            self.nextConnectionRequest(
                                shards: shardsOfRequest,
                                networkState: networkState
                            )
                        }.flatMap { $0.publisher }^
                    )
                    .prefix(untilOutputFrom: selectedNode)^
                    .debug { "3️⃣ findConnectionActions: \($0)" }
                
                let cleanupConnections: AnyPublisher<NodeAction, Never> = findConnectionActions
                    .compactMap { $0 as? ConnectWebSocketAction }^
                    .flatMap { connectWebSocketAction -> AnyPublisher<NodeAction, Never> in
                        let node = connectWebSocketAction.node
                        return selectedNode
                            .filter { $0.node != node }^
                            .map { _ in CloseWebSocketAction(node: node) }^
                    }^
                    .debug { "4️⃣ cleanupConnections: \($0)" }
                
                return findConnectionActions.append(selectedNode)^
                    .merge(with: cleanupConnections)^.debug { "⭐️ woho: \($0)" }
            }^
        
    }
    
    func nextConnectionRequest(shards: Shards, networkState: RadixNetworkState) -> [NodeAction] {
        func nodesWithWebSocketStatus(_ websocketStatus: WebSocketStatus) -> [Node] {
            networkState.nodesWithWebsocketStatus(websocketStatus).map { $0.node }
        }
        
        guard nodesWithWebSocketStatus(.connecting).count < Self.maxSimultaneousConnectionRequests else {
            return []
        }
        
        let disconnectedPeers = nodesWithWebSocketStatus(.disconnected)
        if disconnectedPeers.isEmpty {
            return [DiscoverMoreNodesAction()]
        }
        
        let correctShardNodes = disconnectedPeers
            .filter { node in
                guard let shardSpace = networkState[node]?.shardSpace else { return false }
                return shardsMatcher.does(shardSpace: shardSpace, intersectWithShards: shards)
        }
        
        if let correctShardNodesSet = try? NonEmptySet(array: correctShardNodes) {
            let selectedNode = self.radixPeerSelector.selectPeer(correctShardNodesSet)
            return [ConnectWebSocketAction(node: selectedNode)]
        } else {
            let unknownShardNodes = disconnectedPeers.filter { node in
                guard let state = networkState[node] else {
                    incorrectImplementation("No state for Node: \(node), sounds like a bug?")
                }
                return state.shardSpace == nil
            }
            
            guard !unknownShardNodes.isEmpty else {
                return [DiscoverMoreNodesAction()]
            }
            
            return unknownShardNodes.flatMap { node -> [NodeAction] in
                [
                    GetNodeInfoActionRequest(node: node),
                    GetUniverseConfigActionRequest(node: node)
                ]
            }
            
        }
    }
    
    // swiftlint:enable function_body_length
    
    func filterActionsRequiringNode(_ publisher: AnyPublisher<NodeAction, Never>) -> AnyPublisher<NodeAction, Never> {
        publisher.compactMap { $0 as? FindANodeRequestAction }.eraseToAnyPublisher()
    }
    
}


// MARK: Global
internal extension Publisher {
    
    //    func firstIgnoreOutputFuture() -> Future<Void, Never> {
    //        return Future<Void, Never> { promise in
    //            self.first()
    //                .ignoreOutput()
    //                .eraseToAnyPublisher()
    //            .append(<#T##publisher: Publisher##Publisher#>)
    //        }
    //    }
    
    func debug(
        _ receiveOutputMessage: @escaping (Output) -> String = { "🔮 received output: \($0)" }
    ) -> AnyPublisher<Output, Failure> {
        
        self.handleEvents(
            receiveSubscription: nil,
            receiveOutput: { Swift.print(receiveOutputMessage($0)) },
            receiveCompletion: nil,
            receiveCancel: nil,
            receiveRequest: nil
        ).eraseToAnyPublisher()
    }
}
