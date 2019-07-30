//
//  TokenReferenceBalance.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenReferenceBalance: Equatable, Throwing {
    let tokenResourceIdentifier: ResourceIdentifier
    let amount: NonNegativeAmount
    let owner: Address
    
    public init(
        tokenResourceIdentifier: ResourceIdentifier,
        amount: NonNegativeAmount,
        owner: Address
        ) {
        self.tokenResourceIdentifier = tokenResourceIdentifier
        self.amount = amount
        self.owner = owner
    }
}

public extension TokenReferenceBalance {
    
    init(upTransferrableTokensParticle upParticle: UpParticle<TransferrableTokensParticle>) {
        
        let particle = upParticle.particle
        
        self.init(
            tokenResourceIdentifier: particle.tokenDefinitionReference,
            amount: particle.amount,
            owner: particle.address
        )
    }
    
    init(
        upTransferrableTokensParticles: [UpParticle<TransferrableTokensParticle>],
        tokenIdentifier: ResourceIdentifier,
        owner: Address
    ) throws {
        
        let tokenConsumables = upTransferrableTokensParticles.map { $0.particle }
        
        if tokenConsumables.contains(where: { $0.tokenDefinitionReference != tokenIdentifier }) {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        if tokenConsumables.contains(where: { $0.address != owner }) {
            throw Error.addressMismatch
        }
        
        let amount: NonNegativeAmount = tokenConsumables.map({ $0.amount }).reduce(NonNegativeAmount.zero) { $0 + $1 }
        
        self.init(tokenResourceIdentifier: tokenIdentifier, amount: amount, owner: owner)
    }
    
    enum Error: Swift.Error, Equatable {
        case addressMismatch
        case tokenDefinitionReferenceMismatch
    }
    
    func merging(with other: TokenReferenceBalance) throws -> TokenReferenceBalance {
        
        if other.tokenResourceIdentifier != tokenResourceIdentifier {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        if other.owner != self.owner {
            throw Error.addressMismatch
        }
        
        return TokenReferenceBalance(
            tokenResourceIdentifier: tokenResourceIdentifier,
            amount: amount + other.amount,
            owner: owner
        )
    }
}
