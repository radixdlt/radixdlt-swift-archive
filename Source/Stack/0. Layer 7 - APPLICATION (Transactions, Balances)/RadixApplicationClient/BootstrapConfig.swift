//
//  BootstrapConfig.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol BootstrapConfig {
    var config: UniverseConfig { get }
    var discoveryMode: DiscoveryMode { get }
}

public enum DiscoveryMode {
    case byDiscoveryEpics(NonEmptyArray<RadixNetworkEpic>)
    case byInitialNetworkOfNodes(NonEmptySet<Node>)
}

public extension DiscoveryMode {
    static func byDiscovery(config: UniverseConfig, seedNodes: Observable<Node>) -> DiscoveryMode {
        return .byDiscoveryEpics(
            NonEmptyArray([
                DiscoverNodesEpic(seedNodes: seedNodes, universeConfig: config)
            ])
        )
    }

    static func byOriginNode(_ originNode: Node, nodes: [Node]) -> DiscoveryMode {
        var allNodes = [originNode]
        allNodes.append(contentsOf: nodes)
        do {
            let initialNetworkOfNodes = try NonEmptySet<Node>.init(array: allNodes)
            return .byInitialNetworkOfNodes(initialNetworkOfNodes)
        } catch { incorrectImplementation("Should never happen, set is not empty") }
    }
}
