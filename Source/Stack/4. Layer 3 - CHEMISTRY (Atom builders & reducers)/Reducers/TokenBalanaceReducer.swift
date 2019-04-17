//
//  TokenBalanaceReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct TokenBalanceReducer {
    private let initial: BalancePerToken
    public init(initial: BalancePerToken = [:]) {
        self.initial = initial
    }
}

public typealias SpunTransferrable = SpunParticle<TransferrableTokensParticle>

public extension TokenBalanceReducer {
    func reduce(spunParticles: [AnySpunParticle]) -> BalancePerToken {
        let tokenBalances = spunParticles.compactMap { (spunParticle: AnySpunParticle) -> TokenBalance? in
            guard let transferrableTokensParticle = spunParticle.particle as? TransferrableTokensParticle else {
                return nil
            }
            return TokenBalance(transferrable: transferrableTokensParticle, spin: spunParticle.spin)
        }
        return reduce(tokenBalances: tokenBalances)
    }
    
    func reduce(spunTransferrable: [SpunTransferrable]) -> BalancePerToken {
        let tokenBalances = spunTransferrable.map {
            return TokenBalance(spunTransferrable: $0)
        }
        return reduce(tokenBalances: tokenBalances)
    }

    func reduce(_ spunTransferrable: SpunTransferrable) -> BalancePerToken {
        let tokenBalance = TokenBalance(spunTransferrable: spunTransferrable)
        return reduce(tokenBalances: [tokenBalance])
    }
    
    func reduce(_ transferrableTokensParticle: TransferrableTokensParticle, spin: Spin) -> BalancePerToken {
        let tokenBalance = TokenBalance(transferrable: transferrableTokensParticle, spin: spin)
        return reduce(tokenBalances: [tokenBalance])
    }
    
    func reduce(tokenBalances: [TokenBalance]) -> BalancePerToken {
        return reduce(balancePerToken: BalancePerToken(reducing: tokenBalances))
    }
    
    func reduce(balancePerToken: BalancePerToken) -> BalancePerToken {
        return balancePerToken.merging(with: initial)
    }
    
    func reduce(balancePerTokens: [BalancePerToken]) -> BalancePerToken {
        return balancePerTokens.reduce(initial, { $0.merging(with: $1) })
    }
}

// MARK: - Rx
public extension TokenBalanceReducer {
    
    func reduce(atoms: Observable<[Atom]>) -> Observable<BalancePerToken> {
        return reduce(atoms: atoms.flatMapLatest { Observable.from($0) })
    }
    
    func reduce(atoms: Observable<Atom>) -> Observable<BalancePerToken> {
        let balanceForTokens: Observable<BalancePerToken> = atoms.map { BalancePerToken(reducing: $0.tokensBalances()) }
        return reduce(balanceForTokens: balanceForTokens)
    }
    
    func reduce(spunTransferrable: Observable<SpunTransferrable>) -> Observable<BalancePerToken> {
        return reduce(tokenBalance:
            spunTransferrable.map { TokenBalance(spunTransferrable: $0) }
        )
    }
    
    func reduce(tokenBalance: Observable<TokenBalance>) -> Observable<BalancePerToken> {
        return reduce(balanceForTokens:
            tokenBalance.map { BalancePerToken(reducing: [$0]) }
        )
    }
    
    func reduce(balanceForTokens: Observable<BalancePerToken>) -> Observable<BalancePerToken> {
        return balanceForTokens.scan(initial, accumulator: { (soFar: BalancePerToken, next: BalancePerToken) -> BalancePerToken in
            return soFar.merging(with: next)
        })
    }
}

