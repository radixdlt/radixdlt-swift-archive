//
//  CreateTokenActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class DefaultCreateTokenActionToParticleGroupsMapper: CreateTokenActionToParticleGroupsMapper {
    deinit {
        log.warning("🧨")
    }
}

public extension CreateTokenActionToParticleGroupsMapper {
    func particleGroups(for action: CreateTokenAction) -> ParticleGroups {

        let token = TokenDefinitionParticle(createTokenAction: action)
        let unallocated = UnallocatedTokensParticle.maxSupplyForNewToken(token)
        let rriParticle = ResourceIdentifierParticle(token: token)
        
        let tokenCreationGroup: ParticleGroup = [
            rriParticle.withSpin(.down),
            token.withSpin(.up),
            unallocated.withSpin(.up)
        ]

        let initialSupply = action.initialSupply
        guard let positiveInitialSupply = initialSupply.positiveAmount else {
            return [tokenCreationGroup]
        }
        
        let minted = TransferrableTokensParticle(token: token, amount: NonNegativeAmount(positive: positiveInitialSupply))
        
        var mintGroup: ParticleGroup = [
            unallocated.withSpin(.down),
            minted.withSpin(.up)
        ]
        
        if let positiveLeftOverSupply = initialSupply.subtractedFromMax {
            let unallocatedFromLeftOverSupply = UnallocatedTokensParticle(token: token, amount: positiveLeftOverSupply)
            mintGroup += unallocatedFromLeftOverSupply.withSpin(.up)
        }
        
        return [
            tokenCreationGroup,
            mintGroup
        ]
    }
}
