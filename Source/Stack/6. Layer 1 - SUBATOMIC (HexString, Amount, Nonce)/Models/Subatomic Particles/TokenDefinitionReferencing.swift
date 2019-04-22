//
//  TokenDefinitionReferencing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// A type that references a `TokenDefinitionParticle` using a `ResourceIdentifier`.
///
/// Although this protocol looks very similar to `Identifiable` - which also has
/// a `ResourceIdentifier` property, they are used differently. This is the counterpart
/// of `Identifiable`, a type referencing an `Identifiable` type.
///
/// - seeAlso: `Identifiable`
/// - seeAlso: `ResourceIdentifier`
/// - seeAlso: `TokenDefinitionParticle`
public protocol TokenDefinitionReferencing:
    Accountable,
    Ownable
{
    // swiftlint:enable colon opening_brace
    var tokenDefinitionReference: ResourceIdentifier { get }
}

// MARK: - Ownable
public extension TokenDefinitionReferencing {
    var address: Address {
        return tokenDefinitionReference.address
    }
}

// MARK: - Accountable
public extension TokenDefinitionReferencing {
    var addresses: Addresses {
        return Addresses(address)
    }
}
