//
//  TokenBalance.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenBalance: Hashable, TokenDefinitionReferencing {
    public let amount: SignedAmount
    public let address: Address
    public let tokenDefinitionReference: TokenDefinitionReference
    
    public init(amount: SignedAmount, address: Address, tokenDefinitionReference: TokenDefinitionReference) {
        self.amount = amount
        self.address = address
        self.tokenDefinitionReference = tokenDefinitionReference
    }
    
    public init(consumable: ConsumableTokens, spin: Spin) {
        self.init(
            amount: spin * consumable.amount,
            address: consumable.address,
            tokenDefinitionReference: consumable.tokenDefinitionReference
        )
    }
}

public extension TokenBalance {
    
    enum Error: Swift.Error {
        case addressMismatch
        case tokenDefinitionReferenceMismatch
    }
    
    func merging(with other: TokenBalance) throws -> TokenBalance {
        guard other.address == address else {
            throw Error.addressMismatch
        }
        guard other.tokenDefinitionReference == tokenDefinitionReference else {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        let newAmount = other.amount + amount
        
        return TokenBalance(
            amount: newAmount,
            address: address,
            tokenDefinitionReference: tokenDefinitionReference
        )
    }
}

public extension TokenBalance {
    func hash(into hasher: inout Hasher) {
        hasher.combine(tokenDefinitionReference)
        hasher.combine(address)
    }
    
    static func == (lhs: TokenBalance, rhs: TokenBalance) -> Bool {
        return lhs.tokenDefinitionReference == rhs.tokenDefinitionReference && lhs.address == rhs.address
    }
}

public func * (spin: Spin, amount: Amount) -> SignedAmount {
    switch spin {
    case .down, .neutral: return amount.negated()
    case .up: return amount
    }
}
