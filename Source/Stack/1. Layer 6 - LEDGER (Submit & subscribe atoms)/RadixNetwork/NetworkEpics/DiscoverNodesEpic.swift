//
//  DiscoverNodesEpic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

public final class DiscoverNodesEpic: RadixNetworkEpic {
    private let seedNodes: Observable<Node>
    private let universeConfig: UniverseConfig
    
    public init(seedNodes: Observable<Node>, universeConfig: UniverseConfig) {
        self.seedNodes = seedNodes
        self.universeConfig = universeConfig
    }
}

public extension DiscoverNodesEpic {
    
    // swiftlint:disable:next function_body_length
    func epic(actions: Observable<NodeAction>, networkState: Observable<RadixNetworkState>) -> Observable<NodeAction> {
        let getUniverseConfigsOfSeedNodes: Observable<NodeAction> = actions
            .ofType(DiscoverMoreNodesAction.self)
            .flatMap { [unowned self] _ in self.seedNodes }
            .map { GetUniverseConfigActionRequest(node: $0) as NodeAction }
            .catchError { .just(DiscoverMoreNodesActionError(reason: $0)) }
        
        // TODO Store universe configs in a Node Table instead of filter out Node in FindANodeEpic
        let seedNodesHavingMismatchingUniverse: Observable<NodeAction> = actions
            .ofType(GetUniverseConfigActionResult.self)
            .filter { [unowned self] in $0.result != self.universeConfig }
            .map { [unowned self] in NodeUniverseMismatch(node: $0.node, expectedConfig: self.universeConfig, actualConfig: $0.result) }
        
        let connectedSeedNodes: Observable<Node> = actions
            .ofType(GetUniverseConfigActionResult.self)
            .filter { [unowned self] in $0.result == self.universeConfig }
            .map { $0.node }
            .publish()
            .autoConnect(numberOfSubscribers: 3)
        
        let addSeedNodes: Observable<NodeAction> = connectedSeedNodes.map { AddNodeAction(node: $0) }
        let addSeedNodesInfo: Observable<NodeAction> = connectedSeedNodes.map { GetNodeInfoActionRequest(node: $0) }
        let addSeedNodeSiblings: Observable<NodeAction> = connectedSeedNodes.map { GetLivePeersActionRequest(node: $0) }
        
        let addNodes: Observable<NodeAction> = actions
            .ofType(GetLivePeersActionResult.self)
            .flatMap { (livePeersResult: GetLivePeersActionResult) -> Observable<NodeAction> in
                return Observable.combineLatest(
                    Observable.just(livePeersResult.result),
                    Observable.concat(networkState.firstOrError().asObservable(), Observable.never())
                ) { (nodeInfos, state) in
                    
                    return nodeInfos.compactMap { (nodeInfo: NodeInfo) -> AddNodeAction? in
                        guard
                            let nodeFromInfo = try? Node(nodeInfo: nodeInfo),
                            !state.nodes.containsValue(forKey: nodeFromInfo)
                            else { return nil }
                        return AddNodeAction(node: nodeFromInfo, nodeInfo: nodeInfo)
                        }.asSet.asArray /* removing duplicates */
                    }.flatMap { (addNodeActionList: [AddNodeAction]) -> Observable<NodeAction> in
                        return Observable<NodeAction>.from(addNodeActionList)
                }
        }
    
        return Observable.merge([
            addSeedNodes,
            addSeedNodesInfo,
            addSeedNodeSiblings,
            addNodes,
            getUniverseConfigsOfSeedNodes,
            seedNodesHavingMismatchingUniverse
        ])
        
    }
    
}
