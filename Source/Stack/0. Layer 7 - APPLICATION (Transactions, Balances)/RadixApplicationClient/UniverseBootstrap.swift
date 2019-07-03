//
//  UniverseBootstrap.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct UniverseBootstrap: BootstrapConfig {

    public let config: UniverseConfig
//    public let discoveryEpics: [RadixNetworkEpic]
//    public let initialNetwork: Set<Node>
    public let discoveryMode: DiscoveryMode
    
//    private init(config: UniverseConfig, seedNodes: Observable<Node>) {
//        implementMe()
//    }
    
}

private extension UniverseBootstrap {
    init(config: UniverseConfig, seedNodes: Observable<Node>) {
        self.config = config
        self.discoveryMode = .byDiscovery(config: config, seedNodes: seedNodes)
    }
    
    init(config: UniverseConfig, originNode: Node, nodes: Node...) {
        self.config = config
        self.discoveryMode = DiscoveryMode.byOriginNode(originNode, nodes: nodes)
    }
}

public extension UniverseBootstrap {
//    var config: UniverseConfig {
//        switch self {
//        case .betanet: return .betanet
//        case .localhost: return .localnet
//        }
//    }
//
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
    
//    var nodeFinding: NodeFindingg {
//        switch self {
//        case .betanet:
//            let viaNodeFinder = NodeFinder(originNodeFinder: .betanet)
//            return NodeFindingg.anySuitableNode(
//                config: config,
//                discovery: viaNodeFinder
//            )
//        case .localhost:
//            return NodeFindingg.connectToSpecificNode(
//                url: .localhost,
//                config: config,
//                strategyForWhenNodeIsInsuitable: .throwError
//            )
//        }
//    }
    
}

// MARK: - Presets
public extension UniverseBootstrap {
    static var localhost: UniverseBootstrap {
        return UniverseBootstrap(
            config: .localnet,
            originNode: .localhostWebsocket(port: 8080),
            nodes: .localhostWebsocket(port: 8081)
        )
    }
    
    static var betanet: UniverseBootstrap {
        return UniverseBootstrap(
            config: .betanet,
            seedNodes: OriginNodeFinder.betanet.findSomeOriginNode(port: .nodeFinder).asObservable()
        )
    }
}

private extension Node {
    static func localhostWebsocket(port: Port) -> Node {
        do {
            return try Node(host: Host.local(port: port), isUsingSSL: false)
        } catch { incorrectImplementation("should be able to create localhost node") }
    }
}
