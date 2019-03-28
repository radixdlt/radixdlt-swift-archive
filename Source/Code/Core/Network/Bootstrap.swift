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
    public let nodeDiscovery: NodeDiscovery
}

// MARK: - Presets
public extension Bootstrap {
    
    static var sunstone: Bootstrap {
        return Bootstrap(
            config: .sunstone,
            nodeDiscovery: NodeFinder(
                baseURL: "https://sunstone.radixdlt.com/node-finder",
                port: 443
            )
        )
    }
    
    static var localhost: Bootstrap {
        return Bootstrap(
            config: .betanet,
            nodeDiscovery: NodeDiscoveryHardCoded(
                Node.localhost(port: 8080),
                Node.localhost(port: 8081)
            )
        )
    }

}
