//
//  BootstrapConfig.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol BootstrapConfig {
    var config: UniverseConfig { get }
//    var seeds: Observable<Node> { get }
    var nodeDiscovery: NodeDiscovery { get }
}
