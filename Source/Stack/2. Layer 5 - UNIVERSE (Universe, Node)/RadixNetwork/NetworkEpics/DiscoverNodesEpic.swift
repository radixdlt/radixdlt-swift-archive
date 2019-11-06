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

public final class DiscoverNodesEpic: RadixNetworkEpic {
    private let seedNodes: AnyPublisher<Node, Never>
    private let universeConfig: UniverseConfig
    
    public init(seedNodes: AnyPublisher<Node, Never>, universeConfig: UniverseConfig) {
        self.seedNodes = seedNodes
        self.universeConfig = universeConfig
    }
}

public extension DiscoverNodesEpic {
    
    // swiftlint:disable function_body_length
    
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        let getUniverseConfigsOfSeedNodes: AnyPublisher<NodeAction, Never> = nodeActionPublisher
            .compactMap(typeAs: DiscoverMoreNodesAction.self)
            .flatMap { [unowned self] _ in self.seedNodes }^
            .map { GetUniverseConfigActionRequest(node: $0) as NodeAction }^
        // TODO Combine change epics `actions: AnyPublisher<NodeAction, Never>` to `AnyPublisher<NodeAction, NodeActionsError>`
//            .catchError { .just(DiscoverMoreNodesActionError(reason: $0)) }

        // TODO Store universe configs in a Node Table instead of filter out Node in FindANodeEpic
        let seedNodesHavingMismatchingUniverse: AnyPublisher<NodeAction, Never> = nodeActionPublisher
            .compactMap(typeAs: GetUniverseConfigActionResult.self)
            .filter { [unowned self] in $0.result != self.universeConfig }^
            .map { [unowned self] in NodeUniverseMismatch(node: $0.node, expectedConfig: self.universeConfig, actualConfig: $0.result) }^

        let connectedSeedNodes: AnyPublisher<Node, Never> = nodeActionPublisher
            .compactMap(typeAs: GetUniverseConfigActionResult.self)
            .filter { [unowned self] in $0.result == self.universeConfig }
            .map { $0.node }
            .makeConnectable().autoconnect()^  // .autoConnect(numberOfSubscribers: 3)

        let addSeedNodes: AnyPublisher<NodeAction, Never> = connectedSeedNodes.map { AddNodeAction(node: $0) }^
        let addSeedNodesInfo: AnyPublisher<NodeAction, Never> = connectedSeedNodes.map { GetNodeInfoActionRequest(node: $0) }^
        let addSeedNodeSiblings: AnyPublisher<NodeAction, Never> = connectedSeedNodes.map { GetLivePeersActionRequest(node: $0) }^

        let addNodes: AnyPublisher<NodeAction, Never> = nodeActionPublisher
            .compactMap(typeAs: GetLivePeersActionResult.self)
            .flatMap { (livePeersResult: GetLivePeersActionResult) -> AnyPublisher<NodeAction, Never> in
                return Just(livePeersResult.result).combineLatest(
                    networkStatePublisher
                        .first()^
                        .append(
                            Empty<RadixNetworkState, Never>(completeImmediately: false)
                        )
                ) { (nodeInfos, state) in

                    return nodeInfos.compactMap { (nodeInfo: NodeInfo) -> AddNodeAction? in
                        guard
                            let nodeFromInfo = try? Node(
                                ensureDomainNotNil: nodeInfo.host?.domain,
                                port: livePeersResult.node.host.port,
                                isUsingSSL: livePeersResult.node.isUsingSSL
                            ),
                            !state.nodes.containsValue(forKey: nodeFromInfo)
                            else { return nil }
                        return AddNodeAction(node: nodeFromInfo, nodeInfo: nodeInfo)
                        }.asSet.asArray /* removing duplicates */
                }^
                .flatMap { (addNodeActionList: [AddNodeAction]) -> AnyPublisher<NodeAction, Never> in
                    Just(addNodeActionList).flattenSequence()
                }^
            }^

        return Publishers.MergeMany([
            addSeedNodes,
            addSeedNodesInfo,
            addSeedNodeSiblings,
            addNodes,
            getUniverseConfigsOfSeedNodes,
            seedNodesHavingMismatchingUniverse
        ])^

    }
    
    // swiftlint:enable function_body_length
    
}
