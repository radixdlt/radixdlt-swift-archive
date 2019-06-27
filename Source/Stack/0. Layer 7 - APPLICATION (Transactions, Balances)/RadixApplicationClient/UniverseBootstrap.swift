//
//  UniverseBootstrap.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum UniverseBootstrap: BootstrapConfig {
    case localhost
    case betanet
}
public extension UniverseBootstrap {
    var config: UniverseConfig {
        switch self {
        case .betanet: return .betanet
        case .localhost: return .localnet
        }
    }
    
//    var nodeFindingStrategy: NodeFindingStrategy {
//        switch self {
//        case .betanet:
//            let viaNodeFinder = NodeFinder(originNodeFinder: OriginNodeFinder.betanet)
//            return NodeFindingStrategy.anySuitableNode(discovery: viaNodeFinder, selection: .random)
//        case .localhost:
//            return NodeFindingStrategy.connectToSpecificNode(
//                urlToNode: URLFormatter.localhost,
//                universeConfig: config,
//                ifSpecifiedNodeIsUnsuitable: .throwError
//            )
//        }
//    }
    
    var nodeFinding: NodeFindingg {
        switch self {
        case .betanet:
            let viaNodeFinder = NodeFinder(originNodeFinder: .betanet)
            return NodeFindingg.anySuitableNode(
                config: config,
                discovery: viaNodeFinder
            )
        case .localhost:
            return NodeFindingg.connectToSpecificNode(
                url: .localhost,
                config: config,
                strategyForWhenNodeIsInsuitable: .throwError
            )
        }
    }
}
