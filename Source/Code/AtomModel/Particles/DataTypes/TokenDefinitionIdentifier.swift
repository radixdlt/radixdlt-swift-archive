//
//  TokenDefinitionIdentifier.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Java `TokenClassReference`
public struct TokenDefinitionIdentifier: Identifiable, CustomStringConvertible, Codable, Hashable {
    
    public let address: Address
    public let symbol: Symbol
    
    public init(address: Address, symbol: Symbol) {
        self.address = address
        self.symbol = symbol
    }
}

public extension TokenDefinitionIdentifier {
    init(identifier: ResourceIdentifier) throws {
        let symbol = try Symbol(string: identifier.unique)
        self.init(address: identifier.address, symbol: symbol)
    }
}

// MARK: - Public
public extension TokenDefinitionIdentifier {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: address, type: .tokens, symbol: symbol)
    }
}

// MARK: - Hashable
public extension TokenDefinitionIdentifier {
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

// MARK: - CustomStringConvertible
public extension TokenDefinitionIdentifier {
    var description: String {
        return identifier.identifier
    }
}
