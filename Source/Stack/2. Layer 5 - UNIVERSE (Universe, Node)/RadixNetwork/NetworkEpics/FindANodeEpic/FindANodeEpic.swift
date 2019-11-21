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

// swiftlint:disable all

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
    private let peerSelector: RadixPeerSelector
    private let isPeerSuitable: DetermineIfPeerIsSuitable
    private let isMoreInfoAboutNodeNeeded: DetermineIfMoreInfoAboutNodeIsNeeded
    
    private let waitForConnectionDurationInSeconds: TimeInterval
    
    private let maxSimultaneousConnectionRequests: Int
    
    init(
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable,
        radixPeerSelector: RadixPeerSelector = .default,
        determineIfMoreInfoAboutNodeIsNeeded: DetermineIfMoreInfoAboutNodeIsNeeded = .default,
        
        waitForConnectionDurationInSeconds: TimeInterval = FindANodeEpic.defaultWaitForConnectionDurationInSeconds,
        maxSimultaneousConnectionRequests: Int = FindANodeEpic.defaultMaxSimultaneousConnectionRequests
    ) {
        
        self.peerSelector = radixPeerSelector
        self.isPeerSuitable = determineIfPeerIsSuitable
        self.isMoreInfoAboutNodeNeeded = determineIfMoreInfoAboutNodeIsNeeded
        
        self.waitForConnectionDurationInSeconds = waitForConnectionDurationInSeconds
        self.maxSimultaneousConnectionRequests = maxSimultaneousConnectionRequests
    }
}

// MARK: Public
public extension FindANodeEpic {
    typealias Error = FindANodeError
    static let defaultMaxSimultaneousConnectionRequests = 2
    static let defaultWaitForConnectionDurationInSeconds: TimeInterval = 2
}

public extension FindANodeEpic {
    
    /// This method identifies `NodeAction` which has been marked being dependent on some `RadixNode` (actions conforming to `FindANodeRequestAction`),
    /// e.g. `SubmitAtomActionRequest` (needs to find a _suitable_ node to submit the atom to) and is responsible for finding,
    /// and connecting to a suitable node, doing this by dispatching other potentially required `NodeAction`s to other Network Epics.
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        return nodeActionPublisher.compactMap(typeAs: FindANodeRequestAction.self)
            .combineLatest(
                networkStatePublisher.prepend(RadixNetworkState.empty)
            )
            .flatMap { [weak self] tuple -> AnyPublisher<NodeAction, Never> in
                
                guard let selfNonWeak = self else {
                    return Empty<NodeAction, Never>.init(completeImmediately: true).eraseToAnyPublisher()
                }
                 
                let (findANodeRequestAction, networkState) = tuple
                
                let shardsOfRequest = findANodeRequestAction.shards
                
                func getConnectedNodes(networkState: RadixNetworkState) -> [RadixNodeState] {
                    return networkState.connectedNodes(where: {
                        selfNonWeak.isPeerSuitable.isPeerSuitable($0, shardsOfRequest)
                    })
                }
                
                
                let connectedNodes: AnyPublisher<[RadixNodeState], Never> = networkStatePublisher.map {
                    getConnectedNodes(networkState: $0)
                    }^
                    .prepend(getConnectedNodes(networkState: networkState))^
                   
                // Stream to find node
                let selectedNode: AnyPublisher<NodeAction, Never> = connectedNodes
                    .compactMap { nodeStates in try? NonEmptySet(array: nodeStates.map { $0.node }) }^
                    .first()^
                    .map { selfNonWeak.peerSelector.selectPeer($0) }^
                    .map { FindANodeResultAction(node: $0, request: findANodeRequestAction) as NodeAction }^
                
                // Stream of new actions to find a new node
                let findConnectionActionsStream: AnyPublisher<NodeAction, Never> = connectedNodes
                    .filter { $0.isEmpty }^
                    .first().ignoreOutput()
                    .andThen(
                        Timer.publish(every: selfNonWeak.waitForConnectionDurationInSeconds, on: RadixSchedulers.mainThreadScheduler, in: .common)
                            .autoconnect()^
                            .map { _ -> [NodeAction] in
                                selfNonWeak.findAndConnectToSuitablePeer(shards: shardsOfRequest, networkState: networkState)
                            }
                            .flattenSequence()
                        .removeDuplicates(by: {
                            $0.sameTypeOfActionAndSameNodeAs(other: $1)
                        })
                    )
                    .prefix(untilOutputFrom: selectedNode)^
                    
                    // 🐉 HERE BE DRAGONS 🐉
                    // For some strange reason this `flatMap { Just($0) }`
                    // ( or `handleEvents(receiveOutput:{_ in /* do nothing */ })` )
                    //makes the code work
                    // without it we get nasty crashes in unit tests. Hopefully in Xcode 11.2+
                    // get get better crash reports telling us why it crashes. I've tried
                    // `makeConnectable()` (with or without `.autoconnect()`) instead,
                    // but that didn't fix it.
                    .flatMap { Just($0) }^ // or `.handleEvents(receiveOutput: { _ in })`
                
                // Cleanup and close connections which never worked out
                let cleanupConnections: AnyPublisher<NodeAction, Never> = findConnectionActionsStream
                    .compactMap(typeAs: ConnectWebSocketAction.self)
                    .flatMap { connectWebSocketAction -> AnyPublisher<NodeAction, Never> in
                        let node = connectWebSocketAction.node
                        return selectedNode
                            .map { $0.node }^
                            .filter { selectedNode in selectedNode != node }^
                            .map { _ in CloseWebSocketAction(node: node) }^
                    }^
                
                    
                return findConnectionActionsStream
                    .append(selectedNode)
                    .merge(with: cleanupConnections)
                        .eraseToAnyPublisher()
                    
        }^
    }
}

// MARK: Internal
internal extension FindANodeEpic {
    func findAndConnectToSuitablePeer(
        shards shardsOfRequest: Shards, networkState: RadixNetworkState
    ) -> [NodeAction] {

        // Max pending connections => await, do nothing for now
        if networkState.connectingNodes.count >= maxSimultaneousConnectionRequests { return [] }

        func discoverMore() -> [NodeAction] { [DiscoverMoreNodesAction()] }

        func isSuitablePeer(_ nodeState: RadixNodeState) -> Bool {
            isPeerSuitable.isPeerSuitable(nodeState, shardsOfRequest)
        }


        // We only care about nodes with webSocket status `.disconnected`, because
        // these are the nodes we know of, that we potentially might wanna connect
        // to (if suitable), otherwise we need to find more candidates
        let disconnectedNodes = networkState.disconnectedNodes

        if disconnectedNodes.isEmpty {
            return discoverMore()
        }

        if let disconnectedSuitablePeers = try? NonEmptySet(array: disconnectedNodes.filter { isSuitablePeer($0) }.map { $0.node }) {
            let selectedPeer = peerSelector.selectPeer(disconnectedSuitablePeers)
            return [ConnectWebSocketAction(node: selectedPeer)]
        }

        if case let peersWeNeedMoreInfoAbout = isMoreInfoAboutNodeNeeded.moreInfoIsNeeded(for: disconnectedNodes), !peersWeNeedMoreInfoAbout.isEmpty {
            return peersWeNeedMoreInfoAbout.map { $0.node }
                .flatMap { node -> [NodeAction] in
                    [
                        GetNodeInfoActionRequest(node: node),
                        GetUniverseConfigActionRequest(node: node)
                    ]
            }
        }

        return discoverMore()
    }
}

private extension NodeAction {
    func sameTypeOfActionAndSameNodeAs(other: NodeAction) -> Bool {
        let selfType = Mirror(reflecting: self).subjectType
        let otherType = Mirror(reflecting: other).subjectType
        guard selfType == otherType else {
            return false
        }
        
        // Do NOT perform node comparison if either or is `DiscoverMoreNodesAction` (since that crashes the app)
        if let _ = self as? DiscoverMoreNodesAction, let _ = other as? DiscoverMoreNodesAction {
            return true
        } else if let _ = self as? DiscoverMoreNodesAction {
            return false
        } else if let _ = other as? DiscoverMoreNodesAction {
            return false
        }
      
        return self.node == other.node
    }
}
