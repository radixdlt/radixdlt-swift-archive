//
//  TokenBalanceReferencesReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class TokenBalanceReferencesReducer: ParticleReducer {}
public extension TokenBalanceReferencesReducer {
    
    typealias State = TokenBalanceReferencesState
    
    var initialState: TokenBalanceReferencesState {
        return TokenBalanceReferencesState()
    }
    
    func reduce(state: State, particle: ParticleConvertible) -> State {
        guard let transferrableTokensParticle = particle as? TransferrableTokensParticle else {
            return state
        }
        return state.mergingWithTransferrableTokensParticle(transferrableTokensParticle)
    }

}
