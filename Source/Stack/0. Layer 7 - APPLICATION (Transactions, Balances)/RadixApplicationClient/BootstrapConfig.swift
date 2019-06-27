//
//  BootstrapConfig.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol BootstrapConfig {
    var config: UniverseConfig { get }
//    var nodeFindingStrategy: NodeFindingStrategy { get }
    var nodeFinding: NodeFindingg { get }
}
