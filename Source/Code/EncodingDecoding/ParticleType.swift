//
//  ParticleType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum ParticleType {
    case message
    case tokenDefinition
    case burnedToken
    case mintedToken
    case transferredToken
    case unique
}

public extension ParticleType {
    enum Error: Swift.Error {
        case notParticle
    }
}

internal extension ParticleType {
    init(serializer: RadixModelType) throws {
        switch serializer {
        case .burnedTokenParticle: self = .burnedToken
        case .mintedTokenParticle: self = .mintedToken
        case .uniqueParticle: self = .unique
        case .transferredTokenParticle: self = .transferredToken
        case .messageParticle: self = .message
        case .tokenDefinitionParticle: self = .tokenDefinition
        default: throw Error.notParticle
        }
    }
    
    var serializer: RadixModelType {
        switch self {
        case .burnedToken: return .burnedTokenParticle
        case .message: return .messageParticle
        case .mintedToken: return .mintedTokenParticle
        case .unique: return .uniqueParticle
        case .transferredToken: return .transferredTokenParticle
        case .tokenDefinition: return .tokenDefinitionParticle
        }
    }
}
