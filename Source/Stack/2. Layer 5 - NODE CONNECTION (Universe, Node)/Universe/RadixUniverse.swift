//
//  RadixUniverse.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class RadixUniverse {

    private let config: UniverseConfig
    private let nodeDiscovery: NodeDiscovery

    private init(config: UniverseConfig, nodeDiscovery: NodeDiscovery) {
        self.config = config
        self.nodeDiscovery = nodeDiscovery
    }
}

// MARK: - Presets
public extension RadixUniverse {
    
    static var sunstone: RadixUniverse {
        return RadixUniverse(
            config: .sunstone,
            nodeDiscovery: NodeFinder.sunstone
        )
    }
    
    static var localhost: RadixUniverse {
        return RadixUniverse(
            config: .betanet,
            // swiftlint:disable:next force_try
            nodeDiscovery: try! NodeDiscoveryHardCoded(hosts: [
                "localhost:8080",
                "localhost:8081"
            ])
        )
    }
}
