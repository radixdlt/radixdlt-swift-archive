//
//  ResourceIdentifier.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// A Radix resource identifier is a human readable index into the Ledger which points to a name state machine
///
/// On format: `/:address/:name`, e.g.:
/// `"/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD"`
public struct ResourceIdentifier:
    PrefixedJsonCodable,
    StringRepresentable,
    DSONPrefixedDataConvertible,
    Hashable
{
  
// swiftlint:enable colon opening_brace

    public let address: Address
    public let name: String
    
    public init(address: Address, name: String) {
        self.address = address
        self.name = name
    }
}

// MARK: - Initializers
public extension ResourceIdentifier {
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
        let componentCount = components.count - 1 // ignoring the empty string
        guard componentCount == ResourceIdentifier.componentCount else {
            throw Error.incorrectComponentCount(expected: ResourceIdentifier.componentCount, butGot: componentCount)
        }
        guard components[0].isEmpty else {
            throw Error.unexpectedLeadingPath
        }
        guard case let addressPath = components[ResourceIdentifier.Index.address.rawValue], !addressPath.isEmpty else {
            throw Error.addressPathIsEmpty
        }

        guard case let namePath = components[ResourceIdentifier.Index.name.rawValue], !namePath.isEmpty else {
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
    /// Expect the string: "/address/name", with two separator, to result in these three components: [<ADDRESS>, <NAME/SYMBOL>], not counting the actual first component being the empty string
    static let componentCount = Index.allCases.count
    static let separator = "/"
    enum Index: Int, CaseIterable {
        case address = 1
        case name
    }
}

// MARK: - Error
public extension ResourceIdentifier {
    enum Error: Swift.Error, Equatable {
        case incorrectComponentCount(expected: Int, butGot: Int)
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
