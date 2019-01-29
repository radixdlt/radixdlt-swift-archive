//
//  UniqueParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct UniqueParticle: ParticleConvertible {
    
    // MARK: ParticleConvertible properties
    public let quarks: Quarks
    
    public init(address: Address, unique: String) {
        self.quarks = [
            AccountableQuark(address: address),
            IdentifiableQuark(identifier: ResourceIdentifier(address: address, type: .unique, unique: unique))
        ]
    }
}
