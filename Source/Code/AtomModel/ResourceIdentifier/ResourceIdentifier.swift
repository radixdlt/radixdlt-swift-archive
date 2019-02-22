//
//  ResourceIdentifier.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A Radix resource identifier is a human readable index into the Ledger which points to a unique UP particle.
/// On format: `/:address/:type/:unique`
public struct ResourceIdentifier: Equatable, DsonDecodable, StringInitializable, ExpressibleByStringLiteral, Codable {
   
    public let address: Address
    public let type: ResourceType
    public let unique: String
    
    public init(address: Address, type: ResourceType, unique: String) {
        self.address = address
        self.type = type
        self.unique = unique
    }
}

// MARK: - Initializers
public extension ResourceIdentifier {
    public init(address: Address, type: ResourceType, symbol: Symbol) {
        self.init(address: address, type: type, unique: symbol.value)
    }
    
    public init(address: Address, type: ResourceType, name: Name) {
        self.init(address: address, type: type, unique: name.value)
    }
}

// MARK: - StringInitializable
public extension ResourceIdentifier {
    // swiftlint:disable:next function_body_length
    init(string: String) throws {
        let components = string.components(separatedBy: ResourceIdentifier.separator)
        let componentCount = components.count
        guard componentCount == ResourceIdentifier.componentCount else {
            throw Error.incorrectSeparatorCount(expected: ResourceIdentifier.componentCount, butGot: componentCount)
        }
        guard components[0].isEmpty else {
            throw Error.unexpectedLeadingPath
        }
        guard case let addressPath = components[ResourceIdentifier.addressIndex], !addressPath.isEmpty else {
            throw Error.addressPathIsEmpty
        }

        let typePath = components[ResourceIdentifier.typeIndex]
        guard let type = ResourceType(rawValue: typePath) else {
            throw Error.unsupportedResourceType(got: typePath)
        }
        
        guard case let uniquePath = components[ResourceIdentifier.uniqueIndex], !uniquePath.isEmpty else {
            throw Error.uniquePathEmpty
        }
        
        do {
            self.init(address: try Address(string: addressPath), type: type, unique: uniquePath)
        } catch let addressError as Address.Error {
            throw Error.badAddress(error: addressError)
        }
    }
}

// MARK: - ExpressibleByStringLiteral
public extension ResourceIdentifier {
    init(stringLiteral value: String) {
        do {
            try self.init(string: value)
        } catch {
            fatalError("Passed non ResourceIdentifier string: `\(value)`, error: \(error)")
        }
    }
}

//// MARK: - Encodable
//public extension ResourceIdentifier {
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.unkeyedContainer()
//        try container.encode(Dson<String>(value: identifier))
//    }
//}

// MARK: - Private
private extension ResourceIdentifier {
    static let componentCount = 4
    static let separator = "/"
    static let addressIndex = 1
    static let typeIndex = 2
    static let uniqueIndex = 3
}

// MARK: - Error
public extension ResourceIdentifier {
    public enum Error: Swift.Error {
        case incorrectSeparatorCount(expected: Int, butGot: Int)
        case unexpectedLeadingPath
        case addressPathIsEmpty
        case uniquePathEmpty
        case unsupportedResourceType(got: String)
        case badAddress(error: Address.Error)
    }
}

// MARK: - DsonDecodable
public extension ResourceIdentifier {
    static let tag: DsonTag = .uri
    init(from string: String) throws {
        try self.init(string: string)
    }
}

// MARK: - Public
public extension ResourceIdentifier {
    var identifier: String {
        return [
            "",
            address.base58String.value,
            type.rawValue,
            unique
        ].joined(separator: ResourceIdentifier.separator)
    }
}

// MARK: CustomStringConvertible
extension ResourceIdentifier {
    public var description: String {
        return identifier
    }
}
