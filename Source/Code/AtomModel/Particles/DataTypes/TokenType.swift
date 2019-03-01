//
//  TokenType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum TokenType {
    case minted
    case transferred
    case burned
}

public extension TokenType {
    public enum Error: Swift.Error {
        case notToken
    }
    
    init(particleType: ParticleType) throws {
        switch particleType {
        case .burnedToken: self = .burned
        case .mintedToken: self = .minted
        case .transferredToken: self = .transferred
        default: throw Error.notToken
        }
    }
    
    init(modelType: RadixModelType) throws {
        let particleType = try ParticleType(modelType: modelType)
        try self.init(particleType: particleType)
    }
    
    var particleType: ParticleType {
        switch self {
        case .minted: return .mintedToken
        case .burned: return .burnedToken
        case .transferred: return .transferredToken
        }
    }
}
