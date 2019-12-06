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
@testable import RadixSDK

extension SignedAtom {
    static var irrelevant: Self {
        let unsignedAtom = UnsignedAtom.irrelevant
        return unsignedAtom.signed(signature: .irrelevant, signatureId: .irrelevant)
    }
    
    static func withDestinationAddress(_ address: Address, date: Date = .init()) -> Self {
        let unsignedAtom = UnsignedAtom.withDestinationAddress(address, date: date)
        return unsignedAtom.signed(signature: .irrelevant, signatureId: .irrelevant)
    }
}

extension Signature {
    static var irrelevant: Self {
        try! Signature.init(r: 1, s: 1)
    }
}

extension UnsignedAtom {
    static var irrelevant: Self {
        try! UnsignedAtom(atomWithPow: .irrelevant)
    }
    
    static func withDestinationAddress(_ address: Address, date: Date = .init()) -> Self {
        try! UnsignedAtom(atomWithPow: .withDestinationAddress(address, date: date))
    }
}

extension AtomWithFee {
    static var irrelevant: Self {
        try! AtomWithFee(atomWithoutPow: Atom.irrelevant, proofOfWork: .irrelevant)
    }
    
    static func withDestinationAddress(_ address: Address, date: Date = .init()) -> Self {
         try! AtomWithFee(
            atomWithoutPow: Atom.withDestinationAddress(address, date: date),
            proofOfWork: .irrelevant
        )
    }
}

extension Atom {
    static var irrelevant: Self {
        withDestinationAddress(.irrelevant)
    }
    
    static func withDestinationAddress(_ address: Address, date: Date = .init()) -> Self {
        let particle = ResourceIdentifierParticle(resourceIdentifier: .withAddress(address))
        let particleGroup = try! ParticleGroup(spunParticles: particle.withSpin(.up))
        
        return Atom(
            metaData: .timestamp(date),
            particleGroups: [particleGroup]
        )
    }
}

extension ProofOfWork {
    static var irrelevant: Self {
        Self(seed: Data(), targetNumberOfLeadingZeros: 1, magic: 1, nonce: 0)
    }
}

extension EUID {
    static var irrelevant: Self {
        try! EUID(int: 1)
    }
}

extension ResourceIdentifier {
    static let irrelevant: Self = .withAddress(.irrelevant)
    
    static func withAddress(_ address: Address) -> Self {
        "/\(address)/\(UUID().uuidString.suffix(5))"
    }
}


extension UniverseConfig {
    static let irrelevant = Self.localnet
}

extension NodeInfo {
    static let one = Self(system: .irrelevant, host: .local(port: 1))
    static let two = Self(system: .irrelevant, host: .local(port: 2))
}

extension RadixSystem {
    static let irrelevant = Self(shardSpace: .irrelevant)
}

extension ShardSpace {
    static let irrelevant = try! Self(range: .irrelevant, anchor: 1)
}

extension ShardRange {
    static let irrelevant: Self =  try! Self(lower: 0, upperInclusive: 2)
}

extension Shards {
    static var irrelevant: Self { .init(single: .irrelevant) }
}

func makeNode(index specifiedIndex: UInt8? = nil) -> Node {
    let index: UInt8 = specifiedIndex ?? UInt8.random(in: 100...255)
    return try! Node(domain: "1.1.1.\(index)", port: 1, isUsingSSL: false)
}
