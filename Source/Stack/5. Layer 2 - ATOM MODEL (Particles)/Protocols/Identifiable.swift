//
//  Identifiable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// A type that is identifiable using a `ResourceIdentifier`.
///
/// Since and `ResourceIdentifier` has an `Address`, this type also conforms to `Accoutable`,
/// containing a single address.
///
/// Although this protocol looks very similar to `TokenDefinitionReferencing` - which also has
/// a `ResourceIdentifier` property, they are used differently. This type
/// is defining an identifiable type, whereas `TokenDefinitionReferencing`
/// references this type.
///
/// - seeAlso: `TokenDefinitionReferencing`
/// - seeAlso: `ResourceIdentifier`
/// - seeAlso: `TokenDefinitionParticle`
public protocol Identifiable:
    Accountable,
    Hashable
{
    
    // swiftlint:enable colon opening_brace
    
    var identifier: ResourceIdentifier { get }
}

// MARK: - Accountable
public extension Identifiable {
    var addresses: Addresses {
        return Addresses(identifier.address)
    }
}
