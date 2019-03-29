//
//  TokenDefinitionReference.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// A subset of `ResourceIdentifier` which `type == .tokens`
public struct TokenDefinitionReference:
    PrefixedJsonCodableByProxy,
    TokenDefinitionReferencing,
    Hashable,
    CustomStringConvertible {
// swiftlint:enable colon
    
    public let address: Address
    public let symbol: Symbol
    
    public init(address: Address, symbol: Symbol) {
        self.address = address
        self.symbol = symbol
    }
}

// MARK: - PrefixedJsonDecodableByProxy
public extension TokenDefinitionReference {
    typealias Proxy = ResourceIdentifier
    var proxy: Proxy {
        return identifier
    }
    init(proxy: Proxy) throws {
        try self.init(identifier: proxy)
    }
}

// MARK: - StringInitializable
public extension TokenDefinitionReference {
    init(string: String) throws {
        let identifier = try ResourceIdentifier(string: string)
        try self.init(identifier: identifier)
    }
}

public extension TokenDefinitionReference {
    init(identifier: ResourceIdentifier) throws {
        let symbol = try Symbol(string: identifier.unique)
        self.init(address: identifier.address, symbol: symbol)
    }
}

// MARK: - Public
public extension TokenDefinitionReference {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: address, type: .tokens, symbol: symbol)
    }
}

// MARK: - Hashable
public extension TokenDefinitionReference {
    func hash(into hasher: inout Hasher) {
        hasher.combine(description)
    }
}

// MARK: - TokenDefinitionReferencing
public extension TokenDefinitionReference {
    var tokenDefinitionReference: TokenDefinitionReference {
        return self
    }
}

// MARK: - CustomStringConvertible
public extension TokenDefinitionReference {
    var description: String {
        return identifier.identifier
    }
}

// MARK: - Decodable
public extension TokenDefinitionReference {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rri = try container.decode(ResourceIdentifier.self)
        try self.init(identifier: rri)
    }
}
