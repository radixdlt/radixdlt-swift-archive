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
    case unallocated
    case transferrable
    case resourceIdentifier
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
        case .unallocatedTokensParticle:    self = .unallocated
        case .uniqueParticle:               self = .unique
        case .transferrableTokensParticle:  self = .transferrable
        case .messageParticle:              self = .message
        case .resourceIdentifierParticle:   self = .resourceIdentifier
        case .tokenDefinitionParticle:      self = .tokenDefinition
        default:                            throw Error.notParticle
        }
    }
    
    var serializer: RadixModelType {
        switch self {
        case .unallocated:          return .unallocatedTokensParticle
        case .message:              return .messageParticle
        case .unique:               return .uniqueParticle
        case .resourceIdentifier:   return .resourceIdentifierParticle
        case .transferrable:        return .transferrableTokensParticle
        case .tokenDefinition:      return .tokenDefinitionParticle
        }
    }
}
