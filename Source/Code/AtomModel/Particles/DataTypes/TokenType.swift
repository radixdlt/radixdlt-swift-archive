//
//  TokenType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Adjective version of TokenAction
public enum TokenType: String, StringInitializable, Hashable, Codable {
    case minted
    case transferred
    case burned
}

public extension TokenType {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let particleType = try container.decode(ParticleTypes.self)
        try self.init(particleType: particleType)
    }
}

internal extension TokenType {
    init(particleType: ParticleTypes) throws {
        switch particleType {
        case .burnedToken: self = .burned
        case .mintedToken: self = .minted
        case .transferredToken: self = .transferred
        default: throw Error.particleIsNotTokenType
        }
    }
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
        case particleIsNotTokenType
    }
}
