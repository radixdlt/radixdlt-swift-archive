//
//  OwnedTokensParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt

public struct OwnedTokensParticle: ParticleConvertible {
    private let tokenIdentifier: ResourceIdentifier
    private let granularity: BigUInt
    
    // MARK: ParticleConvertible properties
    public let quarks: Quarks
}
