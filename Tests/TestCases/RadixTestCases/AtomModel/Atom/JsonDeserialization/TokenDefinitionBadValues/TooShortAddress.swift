//
//  TooShortAddress.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class TooShortAddressSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 17
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: too short address") {
            let badJson = self.replaceValueInParticle(for: .address, with: ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCe")
            
            it("should fail to deserialize JSON with too short address") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(type: InvalidStringError.self) {
                    switch $0 {
                    case .tooFewCharacters(let expectedAtLeast, let butGot):
                        expect(expectedAtLeast).to(equal(51))
                        expect(butGot).to(equal(50))
                    default: fail("wrong error")
                    }
                })
            }
        }
    }
}
