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

public extension TokenBalanceReducer {
    func reduce(spunParticles: [SpunParticle]) -> BalancePerToken {
        let tokenBalances = spunParticles.compactMap { (spunParticle: SpunParticle) -> TokenBalance? in
            guard let consumable = spunParticle.particle as? ConsumableTokens else {
                return nil
            }
            return TokenBalance(consumable: consumable, spin: spunParticle.spin)
        }
        return reduce(tokenBalances: tokenBalances)
    }
    
    func reduce(spunConsumables: [SpunConsumable]) -> BalancePerToken {
        let tokenBalances = spunConsumables.map {
            return TokenBalance(spunConsumable: $0)
        }
        return reduce(tokenBalances: tokenBalances)
    }
    
    func reduce(_ spunConsumable: SpunConsumable) -> BalancePerToken {
        let tokenBalance = TokenBalance(spunConsumable: spunConsumable)
        return reduce(tokenBalances: [tokenBalance])
    }
    
    func reduce(_ consumable: ConsumableTokens, spin: Spin) -> BalancePerToken {
        let tokenBalance = TokenBalance(consumable: consumable, spin: spin)
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
    
    func reduce(atomEvents: Observable<[AtomEvent]>) -> Observable<BalancePerToken> {
        let storeEventsOnly = atomEvents.map { $0.compactMap { $0.store } }
        let atomArray: Observable<[Atom]> = storeEventsOnly.map { $0.map { $0.atom } }
        let atoms: Observable<Atom> = atomArray.flatMapLatest { Observable.from($0) }
        return reduce(atoms: atoms)
    }
    
    func reduce(atoms: Observable<Atom>) -> Observable<BalancePerToken> {
        let balanceForTokens: Observable<BalancePerToken> = atoms.map { BalancePerToken(reducing: $0.tokensBalances()) }
        return reduce(balanceForTokens: balanceForTokens)
    }
    
    func reduce(spunConsumables: Observable<SpunConsumable>) -> Observable<BalancePerToken> {
        return reduce(tokenBalance:
            spunConsumables.map { TokenBalance(spunConsumable: $0) }
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
