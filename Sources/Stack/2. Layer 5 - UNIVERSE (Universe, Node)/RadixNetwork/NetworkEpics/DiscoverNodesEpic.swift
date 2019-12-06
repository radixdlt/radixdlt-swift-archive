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
    private let isUniverseSuitable: DetermineIfUniverseIsSuitable
    
    public init(
        seedNodes: AnyPublisher<Node, Never>,
        isUniverseSuitable: DetermineIfUniverseIsSuitable
    ) {
        self.seedNodes = seedNodes
        self.isUniverseSuitable = isUniverseSuitable
    }
}

public extension DiscoverNodesEpic {
    
    // swiftlint:disable function_body_length
    
    func handle(
        actions nodeActionPublisher: AnyPublisher<NodeAction, Never>,
        networkState networkStatePublisher: AnyPublisher<RadixNetworkState, Never>
    ) -> AnyPublisher<NodeAction, Never> {
        
        // swiftlint:enable function_body_length
        
        let getUniverseConfigsOfSeedNodes: AnyPublisher<NodeAction, Never> = nodeActionPublisher
            .compactMap(typeAs: DiscoverMoreNodesAction.self)
            .flatMap { [weak self] _ -> AnyPublisher<Node, Never> in
                guard let selfNonWeak = self else {
                    return Empty<Node, Never>.init(completeImmediately: true).eraseToAnyPublisher()
                }
                return selfNonWeak.seedNodes
            }
            .map { GetUniverseConfigActionRequest(node: $0) as NodeAction }
        .eraseToAnyPublisher()
        // TODO Combine change epics `actions: AnyPublisher<NodeAction, Never>` to `AnyPublisher<NodeAction, NodeActionsError>`
//            .catchError { .just(DiscoverMoreNodesActionError(reason: $0)) }

        let seedNodesHavingMismatchingUniverse: AnyPublisher<NodeAction, Never> = nodeActionPublisher
            .compactMap(typeAs: GetUniverseConfigActionResult.self)
            .filter { [weak self] in
                return self?.isUniverseSuitable.isUniverseSuitableBasedOn(config: $0.result) == false
            }
            .map { NodeUniverseMismatch(getUniverseConfigActionResult: $0) }
            .eraseToAnyPublisher()

        let connectedSeedNodes: AnyPublisher<Node, Never> = nodeActionPublisher
            .compactMap(typeAs: GetUniverseConfigActionResult.self)
            .filter { [weak self] in
                return self?.isUniverseSuitable.isUniverseSuitableBasedOn(config: $0.result) == true
            }
            .map { $0.node }
            .makeConnectable().autoconnect()
            .eraseToAnyPublisher()

        let addSeedNodes: AnyPublisher<NodeAction, Never> = connectedSeedNodes.map { AddNodeAction(node: $0) }
            .eraseToAnyPublisher()
        
        let addSeedNodesInfo: AnyPublisher<NodeAction, Never> = connectedSeedNodes.map { GetNodeInfoActionRequest(node: $0) }
            .eraseToAnyPublisher()

        let addSeedNodeSiblings: AnyPublisher<NodeAction, Never> = connectedSeedNodes.map { GetLivePeersActionRequest(node: $0) }
            .eraseToAnyPublisher()

        let addNodes: AnyPublisher<NodeAction, Never> = nodeActionPublisher
            .compactMap(typeAs: GetLivePeersActionResult.self)
            .flatMap { (livePeersResult: GetLivePeersActionResult) -> AnyPublisher<NodeAction, Never> in
                return Just(livePeersResult.result).combineLatest(
                    networkStatePublisher
                ) { (nodeInfos, state) in

                    return nodeInfos.removeDuplicates().compactMap { (nodeInfo: NodeInfo) -> AddNodeAction? in
                        guard
                            let nodeFromInfo = try? Node(
                                ensureDomainNotNil: nodeInfo.host?.domain,
                                port: nodeInfo.host!.port,
                                isUsingSSL: livePeersResult.node.isUsingSSL
                            ),
                            !state.nodes.containsValue(forKey: nodeFromInfo)
                            else { return nil }
                        return AddNodeAction(node: nodeFromInfo, nodeInfo: nodeInfo)
                        }
                        .map { $0 as NodeAction } /* `AddNodeAction` -> `NodeAction` */
                    }
                .flattenSequence()
            }
            .eraseToAnyPublisher()

        return Publishers.MergeMany([
            addSeedNodes,
            addSeedNodesInfo,
            addSeedNodeSiblings,
            addNodes,
            getUniverseConfigsOfSeedNodes,
            seedNodesHavingMismatchingUniverse
        ])
        .eraseToAnyPublisher()

    }
    
}
