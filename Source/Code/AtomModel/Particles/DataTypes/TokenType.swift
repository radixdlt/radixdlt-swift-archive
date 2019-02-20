//
//  TokenType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Adjective version of TokenAction
public enum TokenType: String, StringInitializable, Hashable {
    case minted
    case transferred
    case burned
}

// MARK: - StringInitializable
public extension TokenType {
    init(string: String) throws {
        guard let type = TokenType(rawValue: string) else {
            throw Error.unsupportedTokenType(string)
        }
        self = type
    }
}

// MARK: CustomStringConvertible
public extension TokenType {
    var description: String {
        return rawValue
    }
}

// MARK: - Error
public extension TokenType {
    public enum Error: Swift.Error {
        case unsupportedTokenType(String)
    }
}
