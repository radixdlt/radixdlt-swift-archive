//
//  TokenPermissions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// The permissions of a Token control who can mint, transfer and burn a Tokens instances under which circumstances.
///
/// For example, typically the creator of a Token restricts minting and burning of their Token to either just themselves for multi-issuance supply or no-one for single-issuance supply.
/// By setting permission restrictions for actions, the Token creator can fine-tune access and usage restrictions to their token. This enables basic economic properties out of the box (e.g. everyone can burn, no-one can trade).
/// The available permissions can be found in the `TokenPermission` enum. For the formal definition read [RIP - Tokens][1].
///
/// - seeAlso:
/// `TokenPermission`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public struct TokenPermissions:
    DictionaryCodable,
    CBORDictionaryConvertible,
    Throwing,
    Equatable
{
    
// swiftlint:enable colon opening_brace
    
    public typealias Key = TokenTransition
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
        self.init(dictionary: map)
    }
}

// MARK: - Access Permissions
public extension TokenPermissions {
    var mintPermission: TokenPermission {
        return valueOfRequiredPermission(.mint)
    }
    var burnPermission: TokenPermission {
        return valueOfRequiredPermission(.burn)
    }
}

private extension TokenPermissions {
    func valueOfRequiredPermission(_ key: TokenTransition) -> TokenPermission {
        guard let permission = dictionary[key] else {
            incorrectImplementation("Expected value for required permission with key: \(key), but got none")
        }
        return permission
    }
}

// MARK: - Throwing
public extension TokenPermissions {
    enum Error: Swift.Error, Equatable {
        case mintMissing
        case burnMissing
    }
}

// MARK: - Presets
public extension TokenPermissions {

    static var all: TokenPermissions {
        return [.mint: .all, .burn: .all]
    }
    
    static var `default`: TokenPermissions = .all
}
