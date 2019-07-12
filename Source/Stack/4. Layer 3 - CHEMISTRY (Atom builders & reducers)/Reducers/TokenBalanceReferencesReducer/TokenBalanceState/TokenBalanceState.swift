//
//  BalancePerToken.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenBalanceReferencesState: ApplicationState, DictionaryConvertible, Equatable {
    public typealias Key = ResourceIdentifier
    public typealias Value = TokenReferenceBalance
    public let dictionary: Map
    public init(dictionary: Map = [:]) {
        self.dictionary = dictionary
    }
    
    public init(reducing balances: [TokenReferenceBalance]) {
        self.init(dictionary: TokenBalanceReferencesState.reduce(balances))
    }
}

public extension TokenBalanceReferencesState {

    func mergingWithTransferrableTokensParticle(_ transferrableTokensParticle: TransferrableTokensParticle) -> TokenBalanceReferencesState {
        let stateFromParticle = TokenBalanceReferencesState(reducing: [TokenReferenceBalance(transferrableTokensParticle: transferrableTokensParticle)])
        return mergingWithState(stateFromParticle)
    }
    
}

public extension TokenBalanceReferencesState {

    static func reduce(_ balances: [TokenReferenceBalance]) -> Map {
        return Map(balances.map { ($0.tokenResourceIdentifier, $0) }, uniquingKeysWith: TokenBalanceReferencesState.conflictResolver)
    }

    static var conflictResolver: (TokenReferenceBalance, TokenReferenceBalance) -> TokenReferenceBalance {
        return { (current, new) in
            do {
                let merged = try current.merging(with: new)
                return merged
            } catch { incorrectImplementation("Unhandled error: \(error)") }
        }
    }

    func mergingWithState(_ otherState: TokenBalanceReferencesState) -> TokenBalanceReferencesState {
        return TokenBalanceReferencesState(
            dictionary: self.dictionary
                .merging(
                    otherState.dictionary,
                    uniquingKeysWith: TokenBalanceReferencesState.conflictResolver
                )
        )
    }

}
