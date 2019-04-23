//
//  Transaction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A transaction of a non-zero amount of a certain token between two Radix accounts
public struct Transaction {
    public let from: Address
    public let to: Address
    public let token: Token
    public let amount: PositiveAmount
    
    public init(from: Address, to: Address, amount: PositiveAmount, token: Token) {
        self.from = from
        self.to = to
        self.amount = amount
        self.token = token
    }
}

public extension Transaction {
    init(from: Address, to: Address, amount: PositiveAmount, radsInUniverse universeConfig: UniverseConfig) {
        let rad = Token.rad(inUniverse: universeConfig)
        self.init(from: from, to: to, amount: amount, token: rad)
    }
}
