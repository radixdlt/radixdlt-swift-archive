//
//  TokenBalances.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenBalances: Equatable {
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
}

public extension TokenBalances {
    func balance(ofToken identifier: ResourceIdentifier) -> TokenBalance? {
        return balancePerToken[identifier]
    }
}
