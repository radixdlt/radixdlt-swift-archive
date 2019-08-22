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

// swiftlint:disable colon

/// Collection of ParticleGroups
public struct ParticleGroups:
    ArrayCodable,
    SpunParticlesOwner,
    DSONArrayConvertible {
 // swiftlint:enable colon
    
    public let particleGroups: [ParticleGroup]
    public init(particleGroups: [ParticleGroup] = []) throws {
        self.particleGroups = particleGroups

        try self.ensureAllAddressesInTheSameUniverse()
    }
}

// MARK: - Convenience
public extension ParticleGroups {
    init(groups: ParticleGroup...) throws {
        try self.init(particleGroups: groups)
    }
}

// MARK: - ArrayDecodable
public extension ParticleGroups {
    typealias Element = ParticleGroup
    var elements: [Element] {
        return particleGroups
    }
    init(elements: [Element]) {
        do {
            try self.init(particleGroups: elements)
        } catch {
            badLiteralValue(elements, error: error)
        }
    }
}

// MARK: - To Atom
public extension ParticleGroups {
    func wrapInAtom() -> Atom {
        return Atom(metaData: .timeNow, particleGroups: self)
    }
}

public extension ParticleGroups {
    
    var spunParticles: [AnySpunParticle] {
        return particleGroups.flatMap { $0.spunParticles }
    }
}
