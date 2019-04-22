//
//  ResourceIdentifier.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// A Radix resource identifier is a human readable index into the Ledger which points to a unique UP particle.
/// On format: `/:address/:type/:unique`
public struct ResourceIdentifier:
    PrefixedJsonCodable,
    StringRepresentable,
    DSONPrefixedDataConvertible,
    Hashable {
// swiftlint:enable colon

    public let address: Address
    public let name: String
    
    public init(address: Address, name: String) {
        self.address = address
        self.name = name
    }
}

// MARK: - Initializers
public extension ResourceIdentifier {
    init(address: Address, name: Name) {
        self.init(address: address, name: name.value)
    }
    init(address: Address, symbol: Symbol) {
        self.init(address: address, name: symbol.value)
    }
}

// MARK: - DSONPrefixSpecifying
public extension ResourceIdentifier {
    var dsonPrefix: DSONPrefix {
        return .radixResourceIdentifier
    }
}

// MARK: - DSONPrefixedDataConvertible
public extension ResourceIdentifier {
    var dborEncodedData: Data {
        return identifier.toData()
    }
}

// MARK: - StringRepresentable
public extension ResourceIdentifier {
    var stringValue: String {
        return identifier
    }
}

// MARK: - StringInitializable
public extension ResourceIdentifier {
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

        guard case let namePath = components[ResourceIdentifier.nameIndex], !namePath.isEmpty else {
            throw Error.namePathEmpty
        }
        
        do {
            self.init(address: try Address(string: addressPath), name: namePath)
        } catch let addressError as Address.Error {
            throw Error.badAddress(error: addressError)
        }
    }
}

// MARK: - Private
private extension ResourceIdentifier {
    static let componentCount = 3
    static let separator = "/"
    static let addressIndex = 1
    static let nameIndex = 2
}

// MARK: - Error
public extension ResourceIdentifier {
    enum Error: Swift.Error {
        case incorrectSeparatorCount(expected: Int, butGot: Int)
        case unexpectedLeadingPath
        case addressPathIsEmpty
        case namePathEmpty
        case badAddress(error: Address.Error)
    }
}

// MARK: - PrefixedJsonDecodable
public extension ResourceIdentifier {
    static let jsonPrefix: JSONPrefix = .uri
}

// MARK: - Public
public extension ResourceIdentifier {
    var identifier: String {
        return [
            "",
            address.base58String.value,
            name
        ].joined(separator: ResourceIdentifier.separator)
    }
}

// MARK: CustomStringConvertible
extension ResourceIdentifier {
    public var description: String {
        return identifier
    }
}
