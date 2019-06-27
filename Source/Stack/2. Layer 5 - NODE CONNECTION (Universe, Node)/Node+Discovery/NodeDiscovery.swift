//
//  NodeDiscovery.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol NodeDiscovery {
    func loadNodes() -> Observable<[Node]>
}

public protocol SuitableNodeDiscovering: NodeDiscovery {
    func findNodes(servingShard shard: Shard, inUniverseHavingConfig config: UniverseConfig, strategyWhenUnsuitable: StrategyWhenNodeIsUnsuitable) -> Observable<[Node]>
    var configOfNode: (Node) -> Observable<UniverseConfig> { get }
}

public extension SuitableNodeDiscovering where Self: NodeDiscovery {
    func findNodesSuitable(for address: Address, inUniverseHavingConfig config: UniverseConfig, strategyWhenUnsuitable: StrategyWhenNodeIsUnsuitable) -> Observable<[Node]> {
        return findNodes(servingShard: address.shard, inUniverseHavingConfig: config, strategyWhenUnsuitable: strategyWhenUnsuitable)
    }
    
    func findNodes(servingShard shard: Shard, inUniverseHavingConfig config: UniverseConfig, strategyWhenUnsuitable: StrategyWhenNodeIsUnsuitable) -> Observable<[Node]> {
        return loadNodes()
            .map {
                if $0.isEmpty, strategyWhenUnsuitable.shouldThrowWhenOffline {
                    throw NodeDiscoveryError.foundZeroNodes
                }
                return $0
            }
            .map { (nodes: [Node]) -> [Node] in
            let nodesThatCanServeShard = nodes.filter { node -> Bool in
                return node.canServe(shard: shard)
            }
            if nodesThatCanServeShard.isEmpty, strategyWhenUnsuitable.shouldThrowWhenShardMismatch {
                throw NodeDiscoveryError.shardMismatch
            }
            return nodesThatCanServeShard
        }.flatMap { (nodesMatchingShard: [Node]) -> Observable<[RadixNodeState]> in
            let stateObservables: [Observable<RadixNodeState>] = nodesMatchingShard.map({ (node: Node) -> Observable<RadixNodeState> in
                self.networkStateOfNode(node)
            })
            return Observable.combineLatest(stateObservables) { $0 }
        }.map { nodeStates in
            let nodesMatchingUniverseConfig = nodeStates.filter { $0.universeConfig == config }.map { $0.node }
            if nodesMatchingUniverseConfig.isEmpty, strategyWhenUnsuitable.shouldThrowWhenUniverseMismatch {
                throw NodeDiscoveryError.universeConfigMismatch
            }
            return nodesMatchingUniverseConfig
        }
    }

    var networkStateOfNode: (Node) -> Observable<RadixNodeState> {
        return { node in
            self.configOfNode(node).map {
                RadixNodeState(node: node, universeConfig: $0)
            }
        }
    }

}

public enum NodeDiscoveryError: Swift.Error, Equatable {
    case foundZeroNodes
    case shardMismatch
    case universeConfigMismatch
}
