//
//  AtomTooBigDSONEncodingTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class AtomTooBigDSONEncodingTests: XCTestCase {
    
    func testDsonEncodingAtomTooBig() {
        // GIVEN
        // An atom with 1000 particles
        let atom = Atom(
            particleGroups: [ParticleGroup(spunParticles: oneThousandParticles)]
        )
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try DSON encode the big Atom
            try atom.toDSON(),
            // THEN
            Atom.Error.tooManyBytes(expectedAtMost: irrelevant(), butGot: irrelevant()),
            "An error saying the atom is too big should be thrown"
        )
        
    }
}

private let oneThousandParticles = [AnySpunParticle](repeating: spunTokenParticle, count: 1000)
private let spunTokenParticle = AnySpunParticle(
    spin: .up,
    particle: UnallocatedTokensParticle(
        amount: 1337,
        tokenDefinitionReference: "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD"
    )
)

func irrelevant<Integer>() -> Integer where Integer: ExpressibleByIntegerLiteral & _ExpressibleByBuiltinIntegerLiteral {
    return Integer.init(integerLiteral: 0)
}
