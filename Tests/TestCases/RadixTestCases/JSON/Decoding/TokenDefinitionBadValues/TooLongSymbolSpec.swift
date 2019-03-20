//
//  AtomJsonDeserializationTokenDefinitionSymbolTooLongSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class TooLongSymbolSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 4
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: too long symbol") {
            let badJson = self.replaceValueInParticle(for: .symbol, with: ":str:01234567890123456")
            it("should fail to deserialize JSON with too long symbol") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(errorType: InvalidStringError.self) {
                    switch $0 {
                    case .tooManyCharacters(let expectedAtMost, let butGot):
                        expect(expectedAtMost).to(equal(16))
                        expect(butGot).to(equal(17))
                    default: fail("wrong error")
                    }
                })
            }
        }
    }
}
