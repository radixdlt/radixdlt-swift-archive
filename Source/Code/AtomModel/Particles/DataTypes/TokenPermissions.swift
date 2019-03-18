//
//  TokenPermissions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable:next colon
public struct TokenPermissions:
    DictionaryCodable,
    CBORDictionaryConvertible,
    Equatable {
    
    public typealias Key = TokenAction
    public typealias Value = TokenPermission
    public let dictionary: [Key: Value]
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
    public init(validate map: Map) throws {
        let keys = map.keys
        guard keys.contains(.burn) else {
            throw Error.burnMissing
        }
        guard keys.contains(.mint) else {
            throw Error.mintMissing
        }
        guard keys.contains(.transfer) else {
            throw Error.transferMissing
        }
        self.init(dictionary: map)
    }
}

public extension TokenPermissions {
    public enum Error: Swift.Error {
        case mintMissing
        case transferMissing
        case burnMissing
    }
}

public extension TokenPermissions {
    static var pow: TokenPermissions {
        return [.mint: .pow, .burn: .pow, .transfer: .pow]
    }
    static var all: TokenPermissions {
        return [.mint: .all, .burn: .all, .transfer: .all]
    }
}
