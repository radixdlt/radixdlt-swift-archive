//
//  TokenBalances.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenBalances: Equatable, Throwing {
    public let balancePerToken: [ResourceIdentifier: TokenBalance]
    public init(balancePerToken: [ResourceIdentifier: TokenBalance]) {
        self.balancePerToken = balancePerToken
    }
}

public extension TokenBalances {
    init(balances: [TokenBalance]) {
        let map = [ResourceIdentifier: TokenBalance](balances.map { (key: $0.token.tokenDefinitionReference, value: $0) }, uniquingKeysWith: { first, _ in return first })
        self.init(balancePerToken: map)
    }
    
    init(
        balanceReferencesState: TokenBalanceReferencesState,
        tokenDefinitionsState: TokenDefinitionsState
    ) throws {
     
        let balances = try balanceReferencesState.dictionary.map { (keyAndValue) throws -> TokenBalance in
            let (rri, tokenReferenceBalance) = keyAndValue
            guard let definition: TokenDefinition = tokenDefinitionsState.tokenDefinition(identifier: rri) else {
                throw Error.tokenDefinitionsStateDoesNotContain(rri: rri)
            }
            let tokenBalance = try TokenBalance(tokenDefinition: definition, tokenReferenceBalance: tokenReferenceBalance)
            return tokenBalance
        }
        self.init(balances: balances)
    }
    
    enum Error: Swift.Error, Equatable {
        case tokenDefinitionsStateDoesNotContain(rri: ResourceIdentifier)
    }
    
}

public extension TokenBalances {
    func balance(of identifier: ResourceIdentifier) -> TokenBalance? {
        return balancePerToken[identifier]
    }
}
