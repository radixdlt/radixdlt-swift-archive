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
    
    func reduce(state: State, upParticle: AnyUpParticle) -> State {
        guard let upTransferrableTokensParticle = try? UpParticle<TransferrableTokensParticle>(anyUpParticle: upParticle) else {
            return state
        }
        return state.mergingWithTransferrableTokensParticle(upTransferrableTokensParticle)
    }

}
