//
//  TokenPermission.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// TODO should this be an optionset?
public enum TokenPermission: String, Codable, DsonConvertible {
    case pow = "pow"
    case genesisOnly = "genesis_only"
    case sameAtomOnly = "same_atom_only"
    case tokenOwnerOnly = "token_owner_only"
    case all = "all"
    case none = "none"
}

// MARK: DsonConvertible
public extension TokenPermission {
    init(from: String) throws {
        guard let permission = TokenPermission(rawValue: from) else {
            throw Error.unsupportedPermission(from)
        }
        self = permission
    }
}

// MARK: - CustomStringConvertible
public extension TokenPermission {
    var description: String {
        return rawValue
    }
}

// MARK: - Error
public extension TokenPermission {
    public enum Error: Swift.Error {
        case unsupportedPermission(String)
    }
}
