//
//  TokenConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol TokenConvertible: TokenDefinitionReferencing, Ownable {
    var symbol: Symbol { get }
    var name: Name { get }
    var address: Address { get }
    var granularity: Granularity { get }
}

// MARK: - Hashable Preparation
public extension TokenConvertible {
    func hash(into hasher: inout Hasher) {
        hasher.combine(symbol)
    }
}

// MARK: - TokenDefinitionReferencing
public extension TokenConvertible {
    var tokenDefinitionReference: TokenDefinitionReference {
        return TokenDefinitionReference(address: address, symbol: symbol)
    }
}
