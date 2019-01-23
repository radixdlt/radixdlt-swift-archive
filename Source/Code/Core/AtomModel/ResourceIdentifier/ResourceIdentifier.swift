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
public struct ResourceIdentifier: Equatable, Codable, CustomStringConvertible {
    private static let componentCount = 3
    public enum Error: Swift.Error {
        case incorrectSeparatorCount(expected: Int, butGot: Int)
        case unexpectedLeadingPath
        case addressPathIsEmpty
        case typePathEmpty
        case uniquePathEmpty
        case badAddress(error: Address.Error)
    }
    
    fileprivate static let separator = "/"
    
    fileprivate let address: Address
    fileprivate static let addressIndex = 1
    fileprivate let type: String
    fileprivate static let typeIndex = 2
    fileprivate let unique: String
    fileprivate static let uniqueIndex = 3
    
    public init(address: Address, type: String, unique: String) {
        self.address = address
        self.type = type
        self.unique = unique
    }
    
    // swiftlint:disable:next function_body_length
    public init(string: String) throws {
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
        guard case let typePath = components[ResourceIdentifier.typeIndex], !typePath.isEmpty else {
            throw Error.typePathEmpty
        }
        guard case let uniquePath = components[ResourceIdentifier.uniqueIndex], !uniquePath.isEmpty else {
            throw Error.uniquePathEmpty
        }
        
        do {
            self.init(address: try Address(string: addressPath), type: typePath, unique: uniquePath)
        } catch let addressError as Address.Error {
            throw Error.badAddress(error: addressError)
        }
    }
}

// MARK: - Public
public extension ResourceIdentifier {
    var identifier: String {
        var map = [Int: String]()
        map[ResourceIdentifier.addressIndex] = address.base58String.value
        map[ResourceIdentifier.typeIndex] = type
        map[ResourceIdentifier.uniqueIndex] = unique
        return ResourceIdentifier.separator + map.values.joined(separator: ResourceIdentifier.separator)
    }
}

// MARK: CustomStringConvertible
extension ResourceIdentifier {
    public var description: String {
        return identifier
    }
}
