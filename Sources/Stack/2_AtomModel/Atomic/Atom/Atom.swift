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

/// The packaging of any transaction to the Radix Ledger, the Atom is the highest level model in the [Atom Model][1], consisting of a list of ParticleGroups, which in turn consists of a list of SpunParticles and metadata.
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/404029477/RIP-1+The+Atom+Model
/// - seeAlso:
/// `ParticleGroup`
///
public struct Atom: Atomic, ExpressibleBySubatomicParts, ArrayConvertible {
    
    public let particleGroups: ParticleGroups
    public let signatures: Signatures
    public let metaData: ChronoMetaData
    
    public init(
        metaData: ChronoMetaData,
        signatures: Signatures,
        particleGroups: ParticleGroups
    ) {
        self.particleGroups = particleGroups
        self.signatures = signatures
        self.metaData = metaData
    }
}

// MARK: ArrayConvertible
public extension Atom {
    typealias Element = ParticleGroup
    var elements: [Element] { return particleGroups.elements }
}

extension Atom: AnyEncodableKeyValuesProcessing {
    
    // Remove "serializer" from hash calculation to match RadixCore `ImmutableAtom` type.
    public var postProcess: Process {
        return { processed, output in
            guard output.contains(.hash) else { return processed }
            var mutable = processed
            mutable.removeAll(where: { $0.key == Atom.CodingKeys.serializer.rawValue })
            return mutable
        }
    }
}

extension Atom: CustomDebugStringConvertible {
    public var debugDescription: String {
        particleGroups.debugDescription
    }
}
