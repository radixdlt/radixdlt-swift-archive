//
//  AtomJsonSerializationTooBigSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class AtomJsonSerializationTooBigSpec: QuickSpec {
    
    override func spec() {
        /// Scenario 3
        /// https://radixdlt.atlassian.net/browse/RLAU-943
        describe("JSON serialization - Too big Atom") {
            let atom = Atom(
                particleGroups: [ParticleGroup(spunParticles: oneHundredParticles)]
            )
            
            it("should fail because it is too big") {
                expect { try JSONEncoder().encode(atom) }.to(throwError { error in
                    guard let atomError = error as? Atom.Error else {
                        return fail("wrong error type")
                    }
                    switch atomError {
                    case .tooManyBytes(let expectedAtMost, let butGot):
                        let maxSize = Atom.maxSize
                        expect(expectedAtMost).to(equal(maxSize))
                        expect(butGot).to(beGreaterThan(maxSize))
                    }
                })
            }
        }
        
    }
}
private let oneHundredParticles = [SpunParticle](repeating: spunTokenParticle, count: 1000)
private let spunTokenParticle = SpunParticle(
    spin: .up,
    particle: TokenParticle(
        type: .mintedToken,
        owner: "A3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9o",
        receiver: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
        nonce: 992284943125945,
        planck: 24805440,
        amount: 1337,
        tokenDefinitionIdentifier: "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
    )
)
