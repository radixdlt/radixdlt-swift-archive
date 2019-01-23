//
//  DefaultLedger.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class DefaultLedger: Ledger {
    public let atomPuller: AtomPuller
    public let atomSubmitter: AtomSubmitter
    
    public let particleStore: ParticleStore
    public let atomStore: AtomStore
    
    init(
        atomPuller: AtomPuller,
        atomSubmitter: AtomSubmitter,
        particleStore: ParticleStore,
        atomStore: AtomStore
        ) {
        self.atomPuller = atomPuller
        self.atomStore = atomStore
        self.particleStore = particleStore
        self.atomSubmitter = atomSubmitter
    }
}
