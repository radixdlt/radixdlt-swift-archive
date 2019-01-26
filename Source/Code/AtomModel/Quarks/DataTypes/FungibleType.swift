//
//  FungibleType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Adjective version of TokenAction
public enum FungibleType: String, StringInitializable, DsonConvertible, Hashable {
    case minted
    case transferred
    case burned
}

// MARK: - StringInitializable
public extension FungibleType {
    init(string: String) throws {
        guard let type = FungibleType(rawValue: string) else {
            throw Error.unsupportedFungibleType(string)
        }
        self = type
    }
}

// MARK: DsonConvertible
public extension FungibleType {
    init(from string: String) throws {
        try self.init(string: string)
    }
}

// MARK: CustomStringConvertible
public extension FungibleType {
    var description: String {
        return rawValue
    }
}

// MARK: - Error
public extension FungibleType {
    public enum Error: Swift.Error {
        case unsupportedFungibleType(String)
    }
}
