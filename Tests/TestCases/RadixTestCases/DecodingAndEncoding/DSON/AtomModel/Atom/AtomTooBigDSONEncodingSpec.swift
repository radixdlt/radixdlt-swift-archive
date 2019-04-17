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
                        let maxSize = Atom.maxSizeOfDSONEncodedAtomInBytes
                        expect(expectedAtMost).to(equal(maxSize))
                        expect(butGot).to(beGreaterThan(maxSize))
                    }
                })
            }
        }
        
    }
}
private let oneThousandParticles = [AnySpunParticle](repeating: spunTokenParticle, count: 1000)
private let spunTokenParticle = AnySpunParticle(
    spin: .up,
    particle: UnallocatedTokensParticle(
        amount: 1337,
        tokenDefinitionReference: "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
    )
)
