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

public protocol Atomic: SpunParticlesOwner, RadixModelTypeStaticSpecifying {
    var particleGroups: ParticleGroups { get }
    var signatures: Signatures { get }
    var metaData: ChronoMetaData { get }
    func identifier() -> AtomIdentifier
}

// MARK: - RadixModelTypeStaticSpecifying
public extension Atomic {
    static var serializer: RadixModelType {
        return .atom
    }
}

public extension Atomic {
    
    /// Shard of each destination address of this atom
    /// This set ought to never be empty
    func shards() throws -> Shards {
        let shards = spunParticles
            .map { $0.particle }
            .flatMap { $0.destinations() }
            .map { $0.shard }
        
        return try Shards(set: shards.asSet)
    }
    
    // HACK
    func requiredFirstShards() throws -> Shards {
        if particles(spin: .down).isEmpty {
            return try shards()
        } else {
            let shards = try spunParticles
                .filter(spin: .down)
                .map { $0.particle }
                .compactMap { try $0.shardables() }
                .flatMap { $0.elements }
                .map { $0.shard }
            return try Shards(set: shards.asSet)
        }
    }
}

public extension Atomic where Self: RadixHashable {
    
    func identifier() -> AtomIdentifier {
        let shards: Shards
        do {
            shards = try self.shards()
        } catch {
            incorrectImplementation("Failed to create AtomIdentifier, could not even create `shards`, error: \(error)")
        }
        
        do {
            return try AtomIdentifier(hash: radixHash, shards: shards)
        } catch {
            incorrectImplementation("Failed to create AtomIdentifier, error: \(error)")
        }
    }
    
    var shortAid: String {
        return identifier().shortAid
    }
    
    // MARK: Equatable
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.radixHash == rhs.radixHash
    }
    
    // MARK: - CustomStringConvertible
    var description: String {
        return "Atom(\(hashEUID))"
    }
    
    // MARK: - CustomDebugStringConvertible
    var debugDescription: String {
        return "Atom(\(hashEUID), pg#\(particleGroups.count), p#\(spunParticles.count), md#\(metaData.count), s#\(signatures.count))"
    }
    
    var signable: Signable {
        return SignableMessage(hash: radixHash)
    }
}

public extension Atomic {
    
    var spunParticles: [AnySpunParticle] {
        return particleGroups.spunParticles
    }
    
    var timestamp: Date {
        return metaData.timestamp
    }
}
