//
//  TokenDefinitionParticle+Identifiable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-08.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Identifiable
public extension TokenDefinitionParticle {
    var identifier: ResourceIdentifier {
        return ResourceIdentifier(address: address, name: name)
    }
}
