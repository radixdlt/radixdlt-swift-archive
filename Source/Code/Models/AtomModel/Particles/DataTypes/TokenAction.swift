//
//  TokenAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Verb version of `FungibleType`
public enum TokenAction: String, Codable, StringInitializable, StringRepresentable, Hashable {
    case mint
    case transfer
    case burn
}

// MARK: - StringInitializable
public extension TokenAction {
    init(string: String) throws {
        guard let type = TokenAction(rawValue: string) else {
            throw Error.unsupportedTokenAction(string)
        }
        self = type
    }
}

// MARK: CustomStringConvertible
public extension TokenAction {
    var description: String {
        return rawValue
    }
}

// MARK: - Error
public extension TokenAction {
    public enum Error: Swift.Error {
        case unsupportedTokenAction(String)
    }
}
