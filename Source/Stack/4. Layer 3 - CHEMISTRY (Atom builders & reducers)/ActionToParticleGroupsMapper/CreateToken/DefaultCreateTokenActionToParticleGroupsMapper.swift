//
//  CreateTokenActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct DefaultCreateTokenActionToParticleGroupsMapper: CreateTokenActionToParticleGroupsMapper {}

public extension DefaultCreateTokenActionToParticleGroupsMapper {
    func particleGroups(for action: CreateTokenAction) -> ParticleGroups {

        let token = TokenDefinitionParticle(createTokenAction: action)
        let unallocated = UnallocatedTokensParticle(token: token, amount: .maxValue256Bits)
        let rriParticle = ResourceIdentifierParticle(token: token)
        
        let tokenCreationGroup: ParticleGroup = [
            rriParticle.withSpin(.down),
            token.withSpin(.up),
            unallocated.withSpin(.up)
        ]

        guard let positiveInitialSupply = try? PositiveAmount(nonNegative: action.initialSupply) else {
            return [tokenCreationGroup]
        }
        
        let minted = TransferrableTokensParticle(token: token, amount: positiveInitialSupply)
        
        var mintGroup: ParticleGroup = [
            unallocated.withSpin(.down),
            minted.withSpin(.up)
        ]
        
        if let positiveLeftOverSupply = try? PositiveAmount(nonNegative: NonNegativeAmount.maxValue256Bits - action.initialSupply) {
            let unallocatedFromLeftOverSupply = UnallocatedTokensParticle(token: token, amount: positiveLeftOverSupply)
            mintGroup += unallocatedFromLeftOverSupply.withSpin(.up)
        }
        
        return [
            tokenCreationGroup,
            mintGroup
        ]
    }
}
