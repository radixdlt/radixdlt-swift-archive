//
//  LookupableTokenBalance.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenBalances: DictionaryConvertible {
    public typealias Key = TokenDefinitionReference
    public typealias Value = TokenBalance
    public var dictionary: Map
    public init(dictionary: Map = [:]) {
        self.dictionary = dictionary
    }
    
    public init(balances: [TokenBalance]) {
        self.init(dictionary: Map(uniqueKeysWithValues: balances.map {
            ($0.tokenDefinitionReference, $0)
        }))
    }
}

public extension TokenBalances {
    mutating func add(consumable: ConsumableTokens, spin: Spin) {
        dictionary[consumable.tokenDefinitionReference] = TokenBalance(consumable: consumable, spin: spin)
    }
    
    func adding(consumable: ConsumableTokens, spin: Spin) -> TokenBalances {
        var copy = self
        copy.add(consumable: consumable, spin: spin)
        return copy
    }
    
    mutating func merge(with other: TokenBalances) throws {
        try dictionary.merge(other.dictionary, uniquingKeysWith: { (current, new) in
            return try current.merging(with: new)
        })
    }
    
    func merging(with other: TokenBalances) throws -> TokenBalances {
        var copy = self
        try copy.merge(with: other)
        return copy
    }
    
    func balanceOrZero(of token: Key, address: Address) -> TokenBalance {
        return valueFor(key: token) ?? TokenBalance(amount: Amount.zero, address: address, tokenDefinitionReference: token)
    }
}
