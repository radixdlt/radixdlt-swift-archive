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
//    private let universeConfig: UniverseConfig
    private let peerSelector: RadixPeerSelector
    private let isPeerSuitable: DetermineIfPeerIsSuitable
    private let isMoreInfoAboutNodeNeeded: DetermineIfMoreInfoAboutNodeIsNeeded
    private let isNodeTooSlowToConnect: DetermineIfNodeIsTooSlowToConnect
    
    private let waitForConnectionDurationInSeconds: TimeInterval
    
    // Internal due to testing
    internal let maxSimultaneousConnectionRequests: Int
    
    private let backgroundQueue = DispatchQueue(label: "FindANodeEpic")
    
    init(
//        universeConfig: UniverseConfig,
        determineIfPeerIsSuitable: DetermineIfPeerIsSuitable, // = .default,
        radixPeerSelector: RadixPeerSelector = .random,
        determineIfMoreInfoAboutNodeIsNeeded: DetermineIfMoreInfoAboutNodeIsNeeded = .default,
        determineIfNodeIsTooSlowToConnect: DetermineIfNodeIsTooSlowToConnect = .default,
        waitForConnectionDurationInSeconds: TimeInterval = FindANodeEpic.defaultWaitForConnectionDurationInSeconds,
        maxSimultaneousConnectionRequests: Int = FindANodeEpic.defaultMaxSimultaneousConnectionRequests
    ) {
//        self.universeConfig = universeConfig
        
        self.peerSelector = radixPeerSelector
        self.isPeerSuitable = determineIfPeerIsSuitable
        self.isMoreInfoAboutNodeNeeded = determineIfMoreInfoAboutNodeIsNeeded
        self.isNodeTooSlowToConnect = determineIfNodeIsTooSlowToConnect
        
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
    func epic(
        actions actionsPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
//        let universeConfig = self.universeConfig
        
        return actionsPublisher.ofType(FindANodeRequestAction.self)
            .combineLatest(
                networkStatePublisher.prepend(RadixNetworkState.empty)
                    //.drop(untilOutputFrom: actionsPublisher.ofType(FindANodeRequestAction.self))
            ) { (action: $0, networkState: $1) }
            .flatMap { [unowned isPeerSuitable, peerSelector] tuple -> AnyPublisher<NodeAction, Never> in
                 
                let (findANodeRequestAction, networkState) = tuple
                
                let shardsOfRequest = findANodeRequestAction.shards
                
                func getConnectedNodes(networkState: RadixNetworkState) -> [RadixNodeState] {
                    return networkState.connectedNodes(where: {
                        isPeerSuitable.isPeer(withState: $0, shards: shardsOfRequest)
                    })
                }
                
                
                let connectedNodes: AnyPublisher<[RadixNodeState], Never> = networkStatePublisher.map {
                    getConnectedNodes(networkState: $0)
                    }^
                     // .replay(1).autoConnect(2);
                    .prepend(getConnectedNodes(networkState: networkState))^
                    .handleEvents(receiveOutput: { print("🔗 connectedNode output: \($0)") })^
                    
                   
//                    .makeConnectable().autoconnect()^
//                    .debug("connectedNodes")
                
                let selectedNode: AnyPublisher<NodeAction, Never> = connectedNodes
                    .compactMap { nodeStates in try? NonEmptySet(array: nodeStates.map { $0.node }) }^
                    .first()^
                    .map { peerSelector.selectPeer($0) }^
                    .map { FindANodeResultAction(node: $0, request: findANodeRequestAction) as NodeAction }^
//                    .share()^ // Equivalent to RxJava: `cache()`
                    .handleEvents(receiveOutput: { print("🎉 selectedNode output: \($0)") })^
//                    .debug("selectedNode")
                
                let findConnectionActionsStream: AnyPublisher<NodeAction, Never> = connectedNodes
//                    .handleEvents(receiveOutput: { print("1️⃣ output: \($0)") })^
                    .filter { $0.isEmpty }^
//                    .handleEvents(receiveOutput: { print("2️⃣ output: \($0)") })^
                    .first()^
//                    .handleEvents(receiveOutput: { print("3️⃣ output: \($0)") })^
                    .ignoreOutput()^
//                    .handleEvents(receiveCompletion: { print("4️⃣ completion: \($0)") })^
                    .flatMap { _ in Empty<NodeAction, Never>.init() }^
                    .append(
                        Timer.publish(every: self.waitForConnectionDurationInSeconds, on: .current, in: .common)
                            .autoconnect()^
//                            .handleEvents(receiveOutput: { print("5️⃣ output: \($0)") })^
                            .map { _ -> [NodeAction] in
                                self.findAndConnectToSuitablePeer(shards: shardsOfRequest, networkState: networkState)
                            }
//                            .handleEvents(receiveOutput: { print("6️⃣ output: \($0)") })^
                            .flattenSequence()
                        .removeDuplicates(by: {
                            $0.sameTypeOfActionAndSameNodeAs(other: $1)
                        })
                    )^
                    .handleEvents(receiveOutput: { print("7️⃣ output: \($0)") })^
                    .prefix(untilOutputFrom: selectedNode)^  // .replay(1).autoConnect(2);
//                    .makeConnectable().autoconnect()^
                    .handleEvents(receiveOutput: { print("8️⃣ output: \($0)") })^
                
                let cleanupConnections: AnyPublisher<NodeAction, Never> = findConnectionActionsStream
                    .ofType(ConnectWebSocketAction.self)
                    .handleEvents(receiveOutput: { print("9️⃣ output: \($0)") })^
                    .flatMap { connectWebSocketAction -> AnyPublisher<NodeAction, Never> in
                        let node = connectWebSocketAction.node
                        return selectedNode
                            .map { $0.node }^
                             .handleEvents(receiveOutput: { print("❓ selected: \($0), connected to: \(node)") })^
                            .filter { selectedNode in selectedNode != node }^
                            .handleEvents(receiveOutput: { print("‼️ found inequality: \($0)") })^
                            .map { _ in CloseWebSocketAction(node: node) }^
                    }^
                .handleEvents(receiveOutput: { print("💇🏻‍♂️ close ws: \($0)") })^
//                    .debug("cleanupConnections")
                
                return findConnectionActionsStream
                    .append(selectedNode)^
                    .merge(with: cleanupConnections)^
        }^
    }
}

private extension NodeAction {
    func sameTypeOfActionAndSameNodeAs(other: NodeAction) -> Bool {
        let selfType = Mirror(reflecting: self).subjectType
        let otherType = Mirror(reflecting: other).subjectType
        guard selfType == otherType else {
            return false
        }
        let sameNode = self.node == other.node
        if sameNode {
            print("Same: \(self) and other: \(other)")
        }
        return sameNode
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
            isPeerSuitable.isPeer(withState: nodeState, shards: shardsOfRequest)
        }


        // We only care about nodes with ws status `.disconnected`, because these are the nodes we know of, that we potentially might wanna connect to (if suitable), otherwise we need to find more candidates
        let disconnectedNodes = networkState.disconnectedNodes

        if disconnectedNodes.isEmpty {
            return discoverMore()
        }

        assert(disconnectedNodes.isEmpty == false)

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


//internal extension FindANodeEpic {
//    func nextConnection(shards: Shards, networkState: RadixNetworkState) -> [NodeAction] {
//
//        func discoverMore() -> [NodeAction] { [DiscoverMoreNodesAction()] }
//
//        func nodesWithWebSocketStatus(_ webSocketStatus: WebSocketStatus) -> [RadixNodeState] {
//            networkState.nodesWithWebsocketStatus(webSocketStatus)
//        }
//
//        guard nodesWithWebSocketStatus(.connecting).count < maxSimultaneousConnectionRequests else {
//            // Max pending connections => await, do nothing for now
//            return []
//        }
//
//        // We only care about nodes with ws status `.disconnected`, because these are the nodes we know of, that we potentially might wanna connect to (if suitable), otherwise we need to find more candidates
//        let candidateNodes = nodesWithWebSocketStatus(.disconnected)
//
//        if candidateNodes.isEmpty {
//            return discoverMore()
//        }
//
//        let correctShardNodes = candidateNodes.filter {
//            self.isPeerSuitable.isPeer(withState: $0, shards: shards)
//        }
//
//        if let correctShardNodesSet = try? NonEmptySet(array: correctShardNodes.map { $0.node }) {
//            let selectedNode = self.peerSelector.selectPeer(correctShardNodesSet)
//            return [ConnectWebSocketAction(node: selectedNode)]
//        } else {
//
//            let moreInfoIsNeededForThese = isMoreInfoAboutNodeNeeded.moreInfoIsNeeded(for: candidateNodes)
//            if moreInfoIsNeededForThese.isEmpty {
//                return discoverMore()
//            }
//
//            return moreInfoIsNeededForThese.map { $0.node }
//                .flatMap { node -> [NodeAction] in
//                    [
//                        GetNodeInfoActionRequest(node: node),
//                        GetUniverseConfigActionRequest(node: node)
//                    ]
//            }
//        }
//    }
//}
