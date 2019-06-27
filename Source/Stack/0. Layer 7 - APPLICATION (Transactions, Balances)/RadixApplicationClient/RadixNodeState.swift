//
//  RadixNodeState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Immutable state at a certain point in time of a RadixNode (`Node`)
public struct RadixNodeState: Equatable {
    public let node: Node
    public let universeConfig: UniverseConfig
}
