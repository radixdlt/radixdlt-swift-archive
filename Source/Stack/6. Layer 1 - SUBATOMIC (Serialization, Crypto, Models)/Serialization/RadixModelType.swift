//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public enum RadixModelType: String, Codable, CaseIterable {

    // MARK: "api"
    case radixSystem                            = "api.system"
    case atomEvent                              = "api.atom_event"
    
    // MARK: "crypto"
    case signature                              = "crypto.ecdsa_signature"
    
    // MARK: "network"
    case nodeInfo                               = "network.peer"
    case udpNodeInfo                            = "network.udp_peer"
    case tcpNodeInfo                            = "network.tcp_peer"
    
    // MARK: "radix"
    case shardSpace                             = "radix.shard.space"
    case atom                                   = "radix.atom"
    case particleGroup                          = "radix.particle_group"
    case spunParticle                           = "radix.spun_particle"
    case universeConfig                         = "radix.universe"
    
    // MARK: - Particles
    case messageParticle                        = "radix.particles.message"
    case resourceIdentifierParticle             = "radix.particles.rri"
    case fixedSupplyTokenDefinitionParticle     = "radix.particles.fixed_supply_token_definition"
    case mutableSupplyTokenDefinitionParticle   = "radix.particles.mutable_supply_token_definition"
    case unallocatedTokensParticle              = "radix.particles.unallocated_tokens"
    case transferrableTokensParticle            = "radix.particles.transferrable_tokens"
    case uniqueParticle                         = "radix.particles.unique"
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
