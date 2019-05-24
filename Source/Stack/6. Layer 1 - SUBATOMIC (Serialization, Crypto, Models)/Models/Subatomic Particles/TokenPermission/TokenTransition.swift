//
//  TokenTransition.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable opening_brace

/// Transition of tokens.
public enum TokenTransition: String,
    StringInitializable,
    StringRepresentable,
    Codable,
    Hashable,
    CustomStringConvertible
{
    
    // swiftlint:enable opening_brace

    case mint
    case burn
}

// MARK: - StringInitializable
public extension TokenTransition {
    init(string: String) throws {
        guard let type = TokenTransition(rawValue: string) else {
            throw Error.unsupportedTokenTransition(string)
        }
        self = type
    }
}

// MARK: CustomStringConvertible
public extension TokenTransition {
    var description: String {
        return rawValue
    }
}

// MARK: - Error
public extension TokenTransition {
    enum Error: Swift.Error {
        case unsupportedTokenTransition(String)
    }
}
