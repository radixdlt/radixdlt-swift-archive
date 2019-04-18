//
//  TokenDefinitionReferencing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol TokenDefinitionReferencing: Identifiable, Accountable, Ownable {
    var tokenDefinitionReference: TokenDefinitionReference { get }
}

public extension TokenDefinitionReferencing {
    var identifier: ResourceIdentifier {
        return tokenDefinitionReference.identifier
    }
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
