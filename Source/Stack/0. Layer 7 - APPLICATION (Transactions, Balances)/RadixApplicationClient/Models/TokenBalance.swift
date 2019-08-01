//
//  TokenBalance.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenBalance: Equatable, Throwing {
    public let token: TokenDefinition
    public let amount: NonNegativeAmount
    public let owner: Address
    
    public init(token tokenConvertible: TokenConvertible, amount: NonNegativeAmount, owner: Ownable) {
        self.token = TokenDefinition(tokenConvertible: tokenConvertible)
        self.amount = amount
        self.owner = owner.address
    }
}

public extension TokenBalance {
    
    enum Error: Swift.Error, Equatable {
        case tokenDefinitionReferenceMismatch
        case transferrableTokens
    }
    
    init(tokenDefinition: TokenConvertible, tokenReferenceBalance: TokenReferenceBalance) throws {
        if tokenDefinition.tokenDefinitionReference != tokenReferenceBalance.tokenResourceIdentifier {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        self.init(
            token: tokenDefinition,
            amount: tokenReferenceBalance.amount,
            owner: tokenReferenceBalance.owner
        )
    }
    
    static func zero(token: TokenDefinition, ownedBy owner: Ownable) -> TokenBalance {
        return TokenBalance(token: token, amount: .zero, owner: owner)
    }
}
