//
//  Symbol.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// The "ticker" for a specific Radix Token, e.g. "XRD" for the token named "Rad". Constrained to a specific
/// character set and length, for the formal definition of these constraints read [RIP - Tokens][1].
///
/// - seeAlso:
/// `TokenDefinitionParticle`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public struct Symbol:
    PrefixedJsonCodable,
    CBORStringConvertible,
    CharacterSetSpecifying,
    MinLengthSpecifying,
    MaxLengthSpecifying {
// swiftlint:enable colon
    
    public static let minLength = 1
    public static let maxLength = 16
    public static let allowedCharacters = CharacterSet.numbersAndUppercaseAtoZ
    
    public let value: String
    
    public init(validated unvalidated: String) {
        do {
            self.value = try Symbol.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension Symbol {
    var description: String {
        return value.description
    }
}
