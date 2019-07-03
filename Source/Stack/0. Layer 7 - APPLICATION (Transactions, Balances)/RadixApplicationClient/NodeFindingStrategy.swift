//
//  NodeFindingStrategy.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//public enum NodeFindingStrategy {
//    case anySuitableNode(
//        discovery: SuitableNodeDiscovering,
//        universeConfig: UniverseConfig,
//        selection: NodeSelection,
//        ifSpecifiedNodeIsUnsuitable: StrategyWhenNodeIsUnsuitable
//    )
//    
//    case connectToSpecificNode(
//        urlToNode: FormattedURL,
//        universeConfig: UniverseConfig,
//        ifSpecifiedNodeIsUnsuitable: StrategyWhenNodeIsUnsuitable
//    )
//}
//
//public extension NodeFindingStrategy {
//    var discovery: SuitableNodeDiscovering {
//        switch self {
//        case .anySuitableNode(let discovery, _, _, _): return discovery
//        case .connectToSpecificNode(let url, let universeConfig, let nodeFindingStrategy):
//            return NodeDiscoveryHardCoded(
//                formattedURLs: [url],
//                universeConfig: universeConfig,
//                strategyIfUnsuitable: nodeFindingStrategy
//            )
//        }
//    }
//    
//    var config: UniverseConfig {
//        switch self {
//        case .anySuitableNode(_, let universeConfig, _, _):
//            return universeConfig
//        case .connectToSpecificNode(_, let universeConfig, _):
//            return universeConfig
//        }
//    }
//    
//    var ifSpecifiedNodeIsUnsuitable: StrategyWhenNodeIsUnsuitable {
//        switch self {
//        case .anySuitableNode(_, _, _, let ifSpecifiedNodeIsUnsuitable): return ifSpecifiedNodeIsUnsuitable
//        case .connectToSpecificNode(_, _, let ifSpecifiedNodeIsUnsuitable):
//            return ifSpecifiedNodeIsUnsuitable
//        }
//    }
//}
//
