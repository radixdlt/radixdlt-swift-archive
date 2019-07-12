//
//  TokenConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol TokenConvertible: TokenDefinitionReferencing {
    var symbol: Symbol { get }
    var name: Name { get }
    var tokenDefinedBy: Address { get }
    var granularity: Granularity { get }
    var description: Description { get }
    var tokenSupplyType: SupplyType { get }
}

// MARK: - Hashable Preparation
public extension TokenConvertible {
    func hash(into hasher: inout Hasher) {
        hasher.combine(tokenDefinitionReference)
    }
}

// MARK: - TokenDefinitionReferencing
public extension TokenConvertible {
    var tokenDefinitionReference: ResourceIdentifier {
        return ResourceIdentifier(address: tokenDefinedBy, symbol: symbol)
    }
}
