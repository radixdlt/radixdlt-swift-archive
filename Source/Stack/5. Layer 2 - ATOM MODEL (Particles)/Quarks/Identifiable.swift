//
//  Identifiable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A type that is identifiable using a `ResourceIdentifier`.
///
/// Although this protocol looks very similar to `TokenDefinitionReferencing` - which also has
/// a `ResourceIdentifier` property, they are used differently. This type
/// is defining an identifiable type, whereas `TokenDefinitionReferencing`
/// references this type.
///
/// - seeAlso: `TokenDefinitionReferencing`
/// - seeAlso: `ResourceIdentifier`
/// - seeAlso: `TokenDefinitionParticle`
public protocol Identifiable: Hashable {
    var identifier: ResourceIdentifier { get }
}
