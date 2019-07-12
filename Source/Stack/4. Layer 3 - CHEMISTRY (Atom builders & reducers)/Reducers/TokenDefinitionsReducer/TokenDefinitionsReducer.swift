//
//  TokenDefinitionsReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class TokenDefinitionsReducer: ParticleReducer {}

public extension TokenDefinitionsReducer {
    
    typealias State = TokenDefinitionsState

    var initialState: TokenDefinitionsState {
        return TokenDefinitionsState()
    }
    
    func reduce(state: State, particle: ParticleConvertible) -> State {
        if let tokenDefinitionParticle = particle as? TokenDefinitionParticle {
            return state.mergeWithTokenDefinitionParticle(tokenDefinitionParticle)
        } else if let unallocatedTokensParticle = particle as? UnallocatedTokensParticle {
            return state.mergeWithUnallocatedTokensParticle(unallocatedTokensParticle)
        } else {
            return state
        }
    }
    
//    func combine(state lhs: State, withOther rhs: State) -> State {
//        return TokenDefinitionsState.combine(state: lhs, with: rhs)
//    }
}
