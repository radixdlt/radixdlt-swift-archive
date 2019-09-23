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

public protocol SpunParticlesOwner {
    var spunParticles: [AnySpunParticle] { get }
}

public extension SpunParticlesOwner {
    func addresses() throws -> Addresses {
        let addresses: [Address] = try spunParticles
            .map { $0.particle }
            .compactMap { try $0.shardables() }
            .flatMap { $0.elements }

        return try Addresses(addresses: Set(addresses))
    }

    func ensureAllAddressesInTheSameUniverse() throws {
        _ = try addresses()
    }
}

public extension ParticleConvertible {
    func withSpin(_ spin: Spin = .up) -> AnySpunParticle {
        return AnySpunParticle(spin: spin, particle: self)
    }
}

// swiftlint:disable colon opening_brace

/// Grouping of Particles relating to each other also holding some metadata
public struct ParticleGroup:
    SpunParticlesOwner,
    RadixCodable,
    RadixHashable,
    ArrayConvertible,
    ArrayInitializable,
    RadixModelTypeStaticSpecifying,
    CustomDebugStringConvertible,
    Codable
{
    // swiftlint:enable colon opening_brace
    
    public static let serializer = RadixModelType.particleGroup
    
    public let spunParticles: [AnySpunParticle]
    public let metaData: MetaData
    
    public init(
        spunParticles: [AnySpunParticle],
        metaData: MetaData = [:]
    ) throws {

        try spunParticles.ensureAllAddressesInTheSameUniverse()

        self.spunParticles = spunParticles
        self.metaData = metaData
    }
}

// MARK: - Convenience
public extension ParticleGroup {
    init(
        spunParticles: AnySpunParticle...,
        metaData: MetaData = [:]
    ) throws {
        try self.init(spunParticles: spunParticles, metaData: metaData)
    }
}

// MARK: - Codable
public extension ParticleGroup {
    enum CodingKeys: String, CodingKey {
        case serializer, version
        
        case spunParticles = "particles"
        case metaData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        spunParticles = try container.decode([AnySpunParticle].self, forKey: .spunParticles)
        metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData) ?? [:]
    }
        
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        var properties = [EncodableKeyValue<CodingKeys>]()
        if !spunParticles.isEmpty {
            properties.append(EncodableKeyValue(key: .spunParticles, value: spunParticles))
        }
        
        if !metaData.isEmpty {
            properties.append(EncodableKeyValue(key: .metaData, value: metaData))
        }
        
        return properties
    }
}

// MARK: - CustomDebugStringConvertible
public extension ParticleGroup {
    var debugDescription: String {
        let particlesDebugDescription = spunParticles.map { $0.debugDescription }.joined(separator: ",\n")
        let particlesString = "[\n\(particlesDebugDescription)\n]"
        
        if metaData.isEmpty { return particlesString }
        return """
            ParticleGroup(
                metaData: \(metaData),
                particles: \(particlesString)
            )
        """
    }
}

// MARK: - ArrayDecodable
public extension ParticleGroup {
    
    typealias Element = AnySpunParticle
    
    var elements: [Element] {
        return spunParticles
    }
    
    init(elements: [Element]) {
        do {
            try self.init(spunParticles: elements)
        } catch {
            badLiteralValue(elements, error: error)
        }
    }
}

// MARK: - Appending Particles
public extension ParticleGroup {
    static func += (group: inout ParticleGroup, spunParticle: AnySpunParticle) throws {
        var allParticles = group.spunParticles
        allParticles.append(spunParticle)
        group = try ParticleGroup(spunParticles: allParticles, metaData: group.metaData)
    }
}

