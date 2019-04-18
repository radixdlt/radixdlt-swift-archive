//
//  RadixModelType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum RadixModelType: String, Codable, CaseIterable {
    case atomEvent                      = "api.atom_event"
    case signature                      = "crypto.ecdsa_signature"
    case nodeInfo                       = "network.peer"
    case radixSystem                    = "api.system"
    case atom                           = "radix.atom"
    case particleGroup                  = "radix.particle_group"
    case spunParticle                   = "radix.spun_particle"
    case udpNodeInfo                    = "network.udp_peer"
    case tcpNodeInfo                    = "network.tcp_peer"
    case universeConfig                 = "radix.universe"

    // MARK: - Particles
    case messageParticle                = "radix.particles.message"
    case tokenDefinitionParticle        = "radix.particles.token_definition"
    case unallocatedTokensParticle      = "radix.particles.unallocated_tokens"
    case transferrableTokensParticle    = "radix.particles.transferrable_tokens"
    case uniqueParticle                 = "radix.particles.unique"
}

public extension RadixModelType {
    
    init(serializerId potentialSerializerId: String) throws {
        guard let serializer = RadixModelType(rawValue: potentialSerializerId) else {
            throw AtomModelDecodingError.unknownSerializer(got: potentialSerializerId)
        }
        
        self = serializer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let serializerId = try container.decode(String.self)
        try self.init(serializerId: serializerId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(serializerId)
    }
    
    var serializerId: String {
        return rawValue
    }
    
    static let jsonKey = "serializer"
}

extension RadixModelType: CBORConvertible {
    public func toCBOR() -> CBOR {
        return CBOR(stringLiteral: serializerId)
    }
}
