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

public protocol ExpressibleBySubatomicParts:
    ArrayInitializable,
    Throwing,
    RadixHashable,
    RadixCodable,
    SignableConvertible,
    CustomStringConvertible,
    Codable,
    Hashable
where
    Element == ParticleGroup,
    CodingKeys == AtomCodingKeys,
    Error == AtomError
{
    // swiftlint:enable colon opening_brace

    init(
        metaData: ChronoMetaData,
        signatures: Signatures,
        particleGroups: ParticleGroups
    )
}

public extension ExpressibleBySubatomicParts {
    init(atomic: Atomic) {
        self.init(
            metaData: atomic.metaData,
            signatures: atomic.signatures,
            particleGroups: atomic.particleGroups
        )
    }
}

// MARK: - AtomCodingKeys
public enum AtomCodingKeys: String, CodingKey {
    case serializer, version
    case particleGroups
    case signatures
    case metaData
}

// MARK: - Throwing
public enum AtomError: Swift.Error, Equatable {
    case tooManyBytes(expectedAtMost: Int, butGot: Int)
}
public extension AtomError {
    static func == (lhs: AtomError, rhs: AtomError) -> Bool {
        switch (lhs, rhs) {
        case (.tooManyBytes, .tooManyBytes): return true
        }
    }
}

// MARK: - Decodable
public extension ExpressibleBySubatomicParts {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let metaData = try container.decode(ChronoMetaData.self, forKey: .metaData)
        
        let signatures = try container.decodeIfPresent(Signatures.self, forKey: .signatures) ?? [:]
        
        let particleGroups = try container.decodeIfPresent(ParticleGroups.self, forKey: .particleGroups) ?? []
        
        self.init(
            metaData: metaData,
            signatures: signatures,
            particleGroups: particleGroups
        )
    }
}
public extension ExpressibleBySubatomicParts where Self: Atomic {
    // MARK: - Encodable
    static var maxSizeOfDSONEncodedAtomInBytes: Int {
        return 60000
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        let properties = [
            EncodableKeyValue<CodingKeys>(key: .metaData, value: metaData),
            EncodableKeyValue(key: .particleGroups, nonEmpty: particleGroups.particleGroups),
            EncodableKeyValue(key: .signatures, nonEmpty: signatures, output: .allButHash)
        ].compactMap { $0 }
        
        let atomSize = try AnyEncodableKeyValueList(keyValues: properties).toDSON().asData.length
        
        guard atomSize <= Self.maxSizeOfDSONEncodedAtomInBytes else {
            throw Error.tooManyBytes(expectedAtMost: Self.maxSizeOfDSONEncodedAtomInBytes, butGot: atomSize)
        }
        
        return properties
    }
    
    var postProcess: Process {
        return { processed, _ in
            return processed
        }
    }
}

// MARK: - ArrayInitializable
public extension ExpressibleBySubatomicParts {
    init(elements particleGroups: [Element]) {
        do {
            try self.init(particleGroups: ParticleGroups(particleGroups: particleGroups))
        } catch {
            badLiteralValue(particleGroups, error: error)
        }
    }
}

// MARK: - Convenience
public extension ExpressibleBySubatomicParts {
    init(
        metaData: ChronoMetaData = .timeNow,
        signatures: Signatures = [:],
        particleGroups: ParticleGroups = []
    ) {
        self.init(metaData: metaData, signatures: signatures, particleGroups: particleGroups)
    }
    
    init(particle: ParticleConvertible, spin: Spin = .up) {
        self.init(
            particleGroups: [
                // swiftlint:disable:next force_try
                try! ParticleGroup(
                    spunParticles: [
                        AnySpunParticle(spin: spin, particle: particle)
                    ]
                )
            ]
        )
    }
}
