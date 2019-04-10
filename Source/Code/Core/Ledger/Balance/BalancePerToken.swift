//
//  LookupableTokenBalance.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct BalancePerToken: DictionaryConvertible {
    public typealias Key = TokenDefinitionReference
    public typealias Value = TokenBalance
    public var dictionary: Map
    public init(dictionary: Map = [:]) {
        self.dictionary = dictionary
    }
    
    public init(reducing balances: [TokenBalance]) {
        self.init(dictionary: BalancePerToken.reduce(balances))
    }
}

public extension BalancePerToken {
    
    static func reduce(_ balances: [TokenBalance]) -> Map {
        return Map(balances.map { ($0.tokenDefinitionReference, $0) }, uniquingKeysWith: BalancePerToken.conflictResolver)
    }
    
    static var conflictResolver: (TokenBalance, TokenBalance) -> TokenBalance {
        return { (current, new) in
            do {
                return try current.merging(with: new)
            } catch let error as TokenBalance.Error {
                switch error {
                case .addressMismatch: incorrectImplementation("Unhandled address mismatch")
                case .tokenDefinitionReferenceMismatch: incorrectImplementation("This should not happen")
                }
            } catch { incorrectImplementation("Unhandled error: \(error)") }
        }
    }
    
    mutating func add(consumable: ConsumableTokens, spin: Spin) {
        dictionary[consumable.tokenDefinitionReference] = TokenBalance(consumable: consumable, spin: spin)
    }
    
    func adding(consumable: ConsumableTokens, spin: Spin) -> BalancePerToken {
        var copy = self
        copy.add(consumable: consumable, spin: spin)
        return copy
    }
    
    mutating func merge(with other: BalancePerToken) {
        dictionary.merge(other.dictionary, uniquingKeysWith: BalancePerToken.conflictResolver)
    }
    
    func merging(with other: BalancePerToken) -> BalancePerToken {
        var copy = self
        copy.merge(with: other)
        return copy
    }
    
    func balanceOrZero(of token: Key, address: Address) -> TokenBalance {
        return valueFor(key: token) ?? TokenBalance(amount: Amount.zero, address: address, tokenDefinitionReference: token)
    }
}
