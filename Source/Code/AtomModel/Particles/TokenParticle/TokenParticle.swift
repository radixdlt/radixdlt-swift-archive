//
//  TokenParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenParticle: ParticleConvertible, Ownable, Fungible, Identifiable {

    public let type: TokenType
    
    public let owner: PublicKey
    public let receiver: Address
    public let nonce: Nonce
    public let planck: Planck
    public let amount: Amount
    public let tokenDefinitionIdentifier: TokenDefinitionIdentifier
}

// MARK: - Identifiable
public extension TokenParticle {
    var identifier: ResourceIdentifier {
        return tokenDefinitionIdentifier.identifier
    }
}
