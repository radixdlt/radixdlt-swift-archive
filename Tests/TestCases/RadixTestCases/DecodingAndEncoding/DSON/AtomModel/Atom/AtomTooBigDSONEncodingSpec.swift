//
//  AtomTooBigDSONEncodingSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class AtomTooBigDSONEncodingSpec: QuickSpec {
    
    override func spec() {
        describe("DSON encoding - Too big Atom") {
            let atom = Atom(
                particleGroups: [ParticleGroup(spunParticles: oneThousandParticles)]
            )
            
            it("should fail because it is too big") {
                expect { try _ = atom.toDSON() }.to(throwError(errorType: Atom.Error.self) {
                    switch $0 {
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
private let oneThousandParticles = [SpunParticle](repeating: spunTokenParticle, count: 1000)
private let spunTokenParticle = SpunParticle(
    spin: .up,
    particle: MintedTokenParticle(
        address: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
        granularity: 1,
        nonce: 992284943125945,
        planck: 24805440,
        amount: 1337,
        tokenDefinitionIdentifier: "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
    )
)
