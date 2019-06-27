//
//  BalancePerToken.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//public extension TokenBalanceReferencesState {
//    
//    
//    func getBalance(definedBy tokenDefinition: TokenDefinition) throws -> TokenBalance? {
//        guard let liteBalance = getBalance(identifier: tokenDefinition.tokenIdentifier) else {
//            return nil
//        }
//        return TokenBalance(token: tokenDefinition, amount: liteBalance.amount, owner: liteBalance.owner)
//    }
//    
//    func getBalance(identifier: ResourceIdentifier) -> TokenBalanceReference? {
//        return tokenBalances[identifier]
//    }
//}

public struct TokenBalanceReferencesState: ApplicationState, DictionaryConvertible, Equatable {
    public typealias Key = ResourceIdentifier
    public typealias Value = TokenReferenceBalance
    public var dictionary: Map
    public init(dictionary: Map = [:]) {
        self.dictionary = dictionary
    }
    
    public init(reducing balances: [TokenReferenceBalance]) {
        self.init(dictionary: TokenBalanceReferencesState.reduce(balances))
    }
}

public extension TokenBalanceReferencesState {

    /*
     	public static TokenBalanceState merge(TokenBalanceState state, TransferrableTokensParticle tokens) {
		HashMap<RRI, BigDecimal> balance = new HashMap<>(state.balance);
		BigDecimal amount = TokenUnitConversions.subunitsToUnits(tokens.getAmount());
		balance.merge(
			tokens.getTokenDefinitionReference(),
			amount,
			BigDecimal::add
		);

		return new TokenBalanceState(balance);
	}
     */
    
    static func merge(state: TokenBalanceReferencesState, transferrableTokensParticle: TransferrableTokensParticle) -> TokenBalanceReferencesState {
        let stateFromParticle = TokenBalanceReferencesState(reducing: [TokenReferenceBalance(transferrableTokensParticle: transferrableTokensParticle)])

        return state.merging(with: stateFromParticle)
    }
    
    static func combine(state lhsState: TokenBalanceReferencesState, with rhsState: TokenBalanceReferencesState) -> TokenBalanceReferencesState {
        if lhsState == rhsState { return lhsState }
        return lhsState.merging(with: rhsState)
    }
}

public extension TokenBalanceReferencesState {
//    static var zeroBalances: TokenBalanceReferencesState {
//        return [:]
//    }
//
    
    static func reduce(_ balances: [TokenReferenceBalance]) -> Map {
        return Map(balances.map { ($0.tokenResourceIdentifier, $0) }, uniquingKeysWith: TokenBalanceReferencesState.conflictResolver)
    }

    static var conflictResolver: (TokenReferenceBalance, TokenReferenceBalance) -> TokenReferenceBalance {
        return { (current, new) in
            do {
                return try current.merging(with: new)
            } catch { incorrectImplementation("Unhandled error: \(error)") }
        }
    }

//    mutating func add(transferrable: TransferrableTokensParticle, spin: Spin) {
//        dictionary[transferrable.tokenDefinitionReference] = TokenBalanceReferenceWithConsumables(transferrable: transferrable, spin: spin)
//    }
//
//    func adding(transferrable: TransferrableTokensParticle, spin: Spin) -> TokenBalanceReferencesState {
//        var copy = self
//        copy.add(transferrable: transferrable, spin: spin)
//        return copy
//    }
//
    mutating func merge(with other: TokenBalanceReferencesState) {
        dictionary.merge(other.dictionary, uniquingKeysWith: TokenBalanceReferencesState.conflictResolver)
    }

    func merging(with other: TokenBalanceReferencesState) -> TokenBalanceReferencesState {
        var copy = self
        copy.merge(with: other)
        return copy
    }
//
//    func balanceOrZero(of token: Key, address: Address) -> TokenBalanceReferenceWithConsumables {
//        return valueFor(key: token) ?? TokenBalanceReferenceWithConsumables(amount: .zero, address: address, tokenDefinitionReference: token)
//    }
}
