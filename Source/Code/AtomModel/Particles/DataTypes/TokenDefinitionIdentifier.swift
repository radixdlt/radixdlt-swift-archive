//
//  TokenDefinitionIdentifier.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Java `TokenClassReference`
public struct TokenDefinitionIdentifier: Identifiable, CustomStringConvertible, Codable, Hashable, ExpressibleByStringLiteral {
    
    public let address: Address
    public let symbol: Symbol
    
    public init(address: Address, symbol: Symbol) {
        self.address = address
        self.symbol = symbol
    }
}

// MARK: - ExpressibleByStringLiteral
public extension TokenDefinitionIdentifier {
    init(stringLiteral value: String) {
        do {
            let identifier = try ResourceIdentifier(from: value)
            try self.init(identifier: identifier)
        } catch {
            fatalError("Invalid ResourceIdentifier, error: \(error)")
        }
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

// MARK: - Decodable
public extension TokenDefinitionIdentifier {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rri = try container.decode(ResourceIdentifier.self)
        try self.init(identifier: rri)
    }
}
