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

// MARK: - Public
public extension RadixUniverse {
    convenience init(bootstrapConfig: BootstrapConfig) {
        self.init(
            config: bootstrapConfig.config,
            nodeDiscovery: bootstrapConfig.nodeDiscovery
        )
    }
}
