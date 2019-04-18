//
//  Name.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// The Name for a specific Radix Token, e.g. "Rad" for the token with the symbol "XRD". Constrained to a specific length, for the formal definition of these constraints read [RIP - Tokens][1].
///
/// - seeAlso:
/// `TokenDefinitionParticle`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public struct Name:
    PrefixedJsonCodable,
    CBORStringConvertible,
    MinLengthSpecifying,
    MaxLengthSpecifying {
// swiftlint:enable colon
    
    public static let minLength = 2
    public static let maxLength = 64
    
    public let value: String
    
    public init(validated unvalidated: String) {
        do {
            self.value = try Name.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension Name {
    var description: String {
        return value.description
    }
}
