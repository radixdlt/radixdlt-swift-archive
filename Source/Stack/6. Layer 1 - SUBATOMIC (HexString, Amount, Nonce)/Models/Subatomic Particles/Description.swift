//
//  Description.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// The description of a specific Radix Token (e.g. "XRD"). Constrained to a specific length.
/// For the formal definition of these constraints read [RIP - Tokens][1].
///
/// - seeAlso:
/// `TokenDefinitionParticle`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public struct Description:
    PrefixedJsonCodable,
    CBORStringConvertible,
    MinLengthSpecifying,
    MaxLengthSpecifying {
// swiftlint:enable colon
    
    public static let minLength = 8
    public static let maxLength = 200
    
    public let value: String
    
    public init(validated unvalidated: String) {
        do {
            self.value = try Description.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension Description {
    var description: String {
        return value.description
    }
}