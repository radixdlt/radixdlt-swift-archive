//
//  TokenBalanaceReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct TokenBalanceReducer: ParticleReducer {
    
    public typealias State = TokenBalanceReferencesState
    
//    private let initial: TokenBalanceReferencesState
//    public init(initial: TokenBalanceReferencesState = [:]) {
//        self.initial = initial
//    }
}

public extension TokenBalanceReducer {
    
    var initialState: State { return TokenBalanceReferencesState() }
    
    func reduce(state: State, particle: ParticleConvertible) -> State {
        guard let transferrableTokensParticle = particle as? TransferrableTokensParticle else { return state }
        return TokenBalanceReferencesState.merge(state: state, transferrableTokensParticle: transferrableTokensParticle)
    }
    
    func combine(state lhsState: State, withOther rhsState: State) -> State {
        return State.combine(state: lhsState, with: rhsState)
    }
}

public typealias SpunTransferrable = SpunParticle<TransferrableTokensParticle>

//public extension TokenBalanceReducer {
//
//    func reduce(spunParticles: [AnySpunParticle]) -> TokenBalanceReferencesState {
//        let tokenBalances = spunParticles.compactMap { (spunParticle: AnySpunParticle) -> TokenBalanceReferenceWithConsumables? in
//            guard let transferrableTokensParticle = spunParticle.particle as? TransferrableTokensParticle else {
//                return nil
//            }
//            return TokenBalanceReferenceWithConsumables(transferrable: transferrableTokensParticle, spin: spunParticle.spin)
//        }
//        return reduce(tokenBalances: tokenBalances)
//    }
//
//    func reduce(spunTransferrable: [SpunTransferrable]) -> TokenBalanceReferencesState {
//        let tokenBalances = spunTransferrable.map {
//            return TokenBalanceReferenceWithConsumables(spunTransferrable: $0)
//        }
//        return reduce(tokenBalances: tokenBalances)
//    }
//
//    func reduce(_ spunTransferrable: SpunTransferrable) -> TokenBalanceReferencesState {
//        let tokenBalance = TokenBalanceReferenceWithConsumables(spunTransferrable: spunTransferrable)
//        return reduce(tokenBalances: [tokenBalance])
//    }
//
//    func reduce(_ transferrableTokensParticle: TransferrableTokensParticle, spin: Spin) -> TokenBalanceReferencesState {
//        let tokenBalance = TokenBalanceReferenceWithConsumables(transferrable: transferrableTokensParticle, spin: spin)
//        return reduce(tokenBalances: [tokenBalance])
//    }
//
//    func reduce(tokenBalances: [TokenBalanceReferenceWithConsumables]) -> TokenBalanceReferencesState {
//        return reduce(balancePerToken: TokenBalanceReferencesState(reducing: tokenBalances))
//    }
//
//    func reduce(balancePerToken: TokenBalanceReferencesState) -> TokenBalanceReferencesState {
//        return balancePerToken.merging(with: initial)
//    }
//
//    func reduce(balancePerTokens: [TokenBalanceReferencesState]) -> TokenBalanceReferencesState {
//        return balancePerTokens.reduce(initial, { $0.merging(with: $1) })
//    }
//}
