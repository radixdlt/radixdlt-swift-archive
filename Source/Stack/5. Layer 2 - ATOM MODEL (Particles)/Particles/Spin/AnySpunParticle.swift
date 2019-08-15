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

// swiftlint:disable colon opening_brace

/// Small container for a `Particle` and its `Spin`. The reason why we do not want to add the `Spin` as a property on the Particle itself is that it would change the Hash of the particle.
public struct AnySpunParticle:
    SpunParticleContainer,
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    RadixHashable,
    Codable,
    CustomStringConvertible
{
// swiftlint:enable colon opening_brace

    public static let serializer = RadixModelType.spunParticle

    public let spin: Spin
    public let particle: ParticleConvertible
    public init(spin: Spin = .down, particle: ParticleConvertible) {
        self.spin = spin
        self.particle = particle
    }
    
    public init(spunParticle: SpunParticleContainer) {
        self.init(
            spin: spunParticle.spin,
            particle: spunParticle.someParticle
        )
    }
}

// MARK: CustomStringConvertible
public extension AnySpunParticle {
    var description: String {
        return "Particle(spin: \(spin), <\(particle)>)"
    }
}

public extension AnySpunParticle {
    var someParticle: ParticleConvertible {
        return particle
    }
}

public extension Array where Element == AnySpunParticle {
    func wrapInGroup() -> ParticleGroup {
        return ParticleGroup(spunParticles: self)
    }
}

public extension AnySpunParticle {
    func wrapInGroup() -> ParticleGroup {
        return ParticleGroup(spunParticles: [self])
    }
    
    func mapToSpunParticle<P>(with: P.Type) -> SpunParticle<P>? {
        return try? SpunParticle<P>(anySpunParticle: self)
    }
}

// MARK: - Deodable
public extension AnySpunParticle {
    
    enum CodingKeys: String, CodingKey {
        case serializer, version
        
        case particle, spin
    }
    
    private enum ParticleTypeKey: String, CodingKey {
        case serializer, version
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        spin = try container.decode(Spin.self, forKey: .spin)

        // Particle
        let particleNestedContainer = try container.nestedContainer(keyedBy: ParticleTypeKey.self, forKey: .particle)
        let particleSerializer = try particleNestedContainer.decode(RadixModelType.self, forKey: .serializer)
        let particleType = try ParticleType(serializer: particleSerializer)
        
        switch particleType {
        case .message:
            particle = try container.decode(MessageParticle.self, forKey: .particle)
        case .transferrable:
            particle = try container.decode(TransferrableTokensParticle.self, forKey: .particle)
        case .unallocated:
            particle = try container.decode(UnallocatedTokensParticle.self, forKey: .particle)
        case .mutableSupplyTokenDefinition:
            particle = try container.decode(MutableSupplyTokenDefinitionParticle.self, forKey: .particle)
        case .fixedSupplyTokenDefinition:
            particle = try container.decode(FixedSupplyTokenDefinitionParticle.self, forKey: .particle)
        case .unique:
            particle = try container.decode(UniqueParticle.self, forKey: .particle)
        case .resourceIdentifier:
            particle = try container.decode(ResourceIdentifierParticle.self, forKey: .particle)
        }
    }
}

// MARK: - Encodable
public extension AnySpunParticle {
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        
        let encodableParticle: EncodableKeyValue<CodingKeys>
        if let messageParticle = particle as? MessageParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: messageParticle)
        } else if let mutableSupplyTokenDefinitionParticle = particle as? MutableSupplyTokenDefinitionParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: mutableSupplyTokenDefinitionParticle)
        } else if let fixedSupplyTokenDefinitionParticle = particle as? FixedSupplyTokenDefinitionParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: fixedSupplyTokenDefinitionParticle)
        } else if let transferrableTokensParticle = particle as? TransferrableTokensParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: transferrableTokensParticle)
        } else if let unallocatedTokenParticle = particle as? UnallocatedTokensParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: unallocatedTokenParticle)
        } else if let uniqueParticle = particle as? UniqueParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: uniqueParticle)
        } else if let resourceIdentifierParticle = particle as? ResourceIdentifierParticle {
            encodableParticle = EncodableKeyValue(key: .particle, value: resourceIdentifierParticle)
        } else {
            incorrectImplementation("Forgot some particle type")
        }
        
        return [
            EncodableKeyValue(key: .spin, value: spin),
            encodableParticle
        ]
    }
}

public extension AnySpunParticle {
    static func up(particle: ParticleConvertible) -> AnySpunParticle {
        return AnySpunParticle(spin: .up, particle: particle)
    }
    
    static func down(particle: ParticleConvertible) -> AnySpunParticle {
        return AnySpunParticle(spin: .down, particle: particle)
    }
}
