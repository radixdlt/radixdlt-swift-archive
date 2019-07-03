////
////  NodeFindingStrategy.swift
////  RadixSDK iOS
////
////  Created by Alexander Cyon on 2019-06-14.
////  Copyright © 2019 Radix DLT. All rights reserved.
////
//
//import Foundation
//
//public struct NodeFindingg {
//    public let connectToNodeMethod: ConnectToNodeMethod
//    public let config: UniverseConfig
//    public let discovery: SuitableNodeDiscovering
//    public let strategyWhenAllNodesAreUnsuitable: StrategyWhenNodeIsUnsuitable
//    
//    private init(
//        connectToNodeMethod: ConnectToNodeMethod,
//        config: UniverseConfig,
//        discovery: SuitableNodeDiscovering,
//        strategyWhenAllNodesAreUnsuitable: StrategyWhenNodeIsUnsuitable
//    ) {
//        self.connectToNodeMethod = connectToNodeMethod
//        self.config = config
//        self.discovery = discovery
//        self.strategyWhenAllNodesAreUnsuitable = strategyWhenAllNodesAreUnsuitable
//    }
//}
//
//public extension NodeFindingg {
//    static func anySuitableNode(
//        config: UniverseConfig,
//        discovery: SuitableNodeDiscovering,
//        selection: NodeSelection = .random
//    ) -> NodeFindingg {
//        
//        return NodeFindingg(
//            connectToNodeMethod: .anySuitableNode(selection: selection),
//            config: config,
//            discovery: discovery,
//            strategyWhenAllNodesAreUnsuitable: .throwError
//        )
//        
//    }
//    
//    static func connectToSpecificNode(
//        url: (FormattedURL),
//        config: UniverseConfig,
//        strategyForWhenNodeIsInsuitable: StrategyWhenNodeIsUnsuitable = .default
//    ) -> NodeFindingg {
//        
//        let discovery = NodeDiscoveryHardCoded(
//            formattedURLs: [url],
//            universeConfig: config,
//            strategyIfUnsuitable: strategyForWhenNodeIsInsuitable
//        )
//        
//        return NodeFindingg(
//            connectToNodeMethod: .connectToSpecificNode(url, ifUnsuitable: strategyForWhenNodeIsInsuitable),
//            config: config,
//            discovery: discovery,
//            strategyWhenAllNodesAreUnsuitable: strategyForWhenNodeIsInsuitable
//        )
//        
//    }
//}
//
