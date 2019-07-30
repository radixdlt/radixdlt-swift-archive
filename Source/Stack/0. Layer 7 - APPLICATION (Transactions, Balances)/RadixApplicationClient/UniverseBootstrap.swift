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
    public let discoveryMode: DiscoveryMode
}

private extension UniverseBootstrap {
    init(config: UniverseConfig, seedNodes: Observable<Node>) {
        self.config = config
        self.discoveryMode = .byDiscovery(config: config, seedNodes: seedNodes)
    }
    
    init(config: UniverseConfig, originNode: Node, nodes: Node...) {
        self.config = config
        self.discoveryMode = .byOriginNode(originNode, nodes: nodes)
    }
}

// MARK: - CustomDebugStringConvertible
public extension UniverseBootstrap {
    var debugDescription: String {
        return """
        UniverseConfig: \(config.debugDescription),
        DiscoveryMode: \(discoveryMode.debugDescription)
        """
    }
}

// MARK: - Presets
public extension UniverseBootstrap {
    static var localhostTwoNodes: UniverseBootstrap {
        return UniverseBootstrap(
            config: .localnet,
            originNode: .localhostWebsocket(port: 8080),
            nodes: .localhostWebsocket(port: 8081)
        )
    }
    
    static var localhostSingleNode: UniverseBootstrap {
        return UniverseBootstrap(
            config: .localnet,
            originNode: .localhostWebsocket(port: 8080)
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
