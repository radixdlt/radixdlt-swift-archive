//
//  Atom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Atom
public struct Atom: AtomConvertible {
    
    public let particleGroups: ParticleGroups
    public let signatures: Signatures
    public let metaData: MetaData
    
    public init(particleGroups: ParticleGroups = [], signatures: Signatures = [:], metaData: MetaData = [:]) {
        self.particleGroups = particleGroups
        self.signatures = signatures
        self.metaData = metaData
    }
}
