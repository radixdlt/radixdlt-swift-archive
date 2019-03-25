//
//  Bootstrap.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct Bootstrap: BootstrapConfig {
    public let config: UniverseConfig
    public let seeds: Observable<Node>
}

// MARK: - Presets
public extension Bootstrap {
    static var betanet: Bootstrap {
        return Bootstrap(
            config: .betanet,
            seeds: Observable<Node>.of(
                Node.localhost(port: 8080),
                Node.localhost(port: 8081)
        ))
    }
    
    static var sunstone: Bootstrap {
        return Bootstrap(
            config: .sunstone,
            seeds: NodeFinder(
                baseURL: "https://sunstone.radixdlt.com/node-finder",
                port: 443
            ).getSeed()
        )
    }
}
