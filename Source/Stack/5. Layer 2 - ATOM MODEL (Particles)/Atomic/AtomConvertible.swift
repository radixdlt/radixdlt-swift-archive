//
//  AtomConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AtomConvertible: Atomic {
    var atomic: Atomic { get }
}

// MARK: - AtomConvertible + Atomic
public extension AtomConvertible {
    var particleGroups: ParticleGroups { return atomic.particleGroups }
    var signatures: Signatures { return atomic.signatures }
    var metaData: ChronoMetaData { return atomic.metaData }
}
