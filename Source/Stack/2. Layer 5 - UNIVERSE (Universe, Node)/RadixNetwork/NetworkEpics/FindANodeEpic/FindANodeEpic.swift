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
import Entwine

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
    private let determineIfPeerIsSuitable: DetermineIfPeerIsSuitable
    private let nextConnection: NextConnection
    
    init(
        radixPeerSelector: RadixPeerSelector = .random,
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable = .default,
        determineIfMoreInfoOfNodeIsNeeded: NextConnection.DetermineIfMoreInfoIsNeeded = .ifShardSpaceIsUnknown
    ) {
        
        self.radixPeerSelector = radixPeerSelector
        self.determineIfPeerIsSuitable = determineIfPeerIsSuitable
        
        self.nextConnection = NextConnection(
            radixPeerSelector: radixPeerSelector,
            determineIfPeerIsSuitable: determineIfPeerIsSuitable,
            determineIfMoreInfoIsNeeded: determineIfMoreInfoOfNodeIsNeeded
        )
    }
}

// MARK: Public
public extension FindANodeEpic {
    
    typealias Error = FindANodeError
    
    static let maxSimultaneousConnectionRequests = 2
}

public extension FindANodeEpic {
    
    /// This method identifies `NodeAction` which has been marked being dependent on some `RadixNode` (actions conforming to `FindANodeRequestAction`),
    /// e.g. `SubmitAtomActionRequest` (needs to find a _suitable_ node to submit the atom to) and is responsible for finding,
    /// and connecting to a suitable node, doing this by dispatching other potentially required `NodeAction`s to other Network Epics.
    func epic(
        actions actionsPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        return actionsPublisher
            .compactMap { $0 as? FindANodeRequestAction }^
            .flatMap { [unowned determineIfPeerIsSuitable, radixPeerSelector, nextConnection] findANodeRequestAction -> AnyPublisher<NodeAction, Never> in
                
                let shardsOfRequest = findANodeRequestAction.shards
                
                let connectedNodes = Milestones.milestoneConnectedNodes(
                    networkState: networkStatePublisher,
                    shards: shardsOfRequest,
                    determineIfPeerIsSuitable: determineIfPeerIsSuitable
                )
                
                let selectedNode = Milestones.milestoneSelectedNode(
                    connectedNodes: connectedNodes,
                    radixPeerSelector: radixPeerSelector,
                    findANodeRequestAction: findANodeRequestAction
                )
                
                let findConnectionActions = Milestones.milestoneConnectionFor(
                    connectedNode: connectedNodes,
                    selectedNode: selectedNode,
                    networkState: networkStatePublisher,
                    shards: shardsOfRequest,
                    nextConnection: nextConnection
                )
                
                let cleanupConnections = Milestones.milestoneCleanup(
                    findConnection: findConnectionActions,
                    selectedNode: selectedNode
                )
                
                let selectNodeAndConnect = findConnectionActions.append(selectedNode)^
                
                return selectNodeAndConnect.merge(with: cleanupConnections)^
            }^
    }
}

public extension FindANodeEpic {
    enum Milestones {}
}

internal extension FindANodeEpic.Milestones {
    
    static func milestoneConnectedNodes(
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>,
        shards: Shards,
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable
    ) -> AnyPublisher<[RadixNodeState], Never> {
        
        networkStatePublisher.map { networkState in
            networkState.connectedNodes { nodeState in
                determineIfPeerIsSuitable.isPeer(withState: nodeState, suitableBasedOnShards: shards)
            }
            
        }^
    }
    
    static func milestoneSelectedNode(
        connectedNodes: AnyPublisher<[RadixNodeState], Never>,
        radixPeerSelector: RadixPeerSelector,
        findANodeRequestAction: FindANodeRequestAction
    ) -> AnyPublisher<NodeAction, Never> {
        
        return connectedNodes
            .compactMap { nodeStates in try? NonEmptySet<Node>(array: nodeStates.map { $0.node }) }^
            .first()^
            .map { radixPeerSelector.selectPeer($0) }^
            .map { selectedNode in
                FindANodeResultAction(node: selectedNode, request: findANodeRequestAction)
            }^
    }
    
    // swiftlint:disable:next function_parameter_count
    static func milestoneConnectionFor(
        connectedNode connectedNodePublisher: AnyPublisher<[RadixNodeState], Never>,
        selectedNode selectedNodePublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>,
        shards: Shards,
        nextConnection: NextConnection
    ) -> AnyPublisher<NodeAction, Never> {
        
        connectedNodePublisher
            .filter { $0.isEmpty }^
            .first()^
            .ignoreOutput()^
            .flatMap { _ in Empty<NodeAction, Never>() }^
            .append(
                networkStatePublisher.map { networkState in
                    nextConnection.nextConnection(
                        shards: shards,
                        networkState: networkState
                    )
                }
                .flatMap { $0.publisher }^
            )^
            .prefix(untilOutputFrom: selectedNodePublisher)^
            .debug("findConnection")
    }
    
    static func milestoneCleanup(
        findConnection findConnectionPublisher: AnyPublisher<NodeAction, Never>,
        selectedNode selectedNodePublisher: AnyPublisher<NodeAction, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        findConnectionPublisher
            .compactMap { $0 as? ConnectWebSocketAction }^
            .flatMap { connectWebSocketAction -> AnyPublisher<NodeAction, Never> in
                let node = connectWebSocketAction.node
                return selectedNodePublisher
                    .filter { $0.node != node }^
                    .map { _ in CloseWebSocketAction(node: node) }^
            }^
    }
}
