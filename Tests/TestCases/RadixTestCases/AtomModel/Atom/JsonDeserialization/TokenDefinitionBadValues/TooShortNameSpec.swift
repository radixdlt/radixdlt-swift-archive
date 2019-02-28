//
//  TooShortNameSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class TooShortNameSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 8
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: too short name") {
            let badJson = self.replaceValueInParticle(for: .name, with: ":str:B")
            
            it("should fail to deserialize JSON with a too short name") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(type: InvalidStringError.self) {
                    switch $0 {
                    case .tooFewCharacters(let expectedAtLeast, let butGot):
                        expect(expectedAtLeast).to(equal(2))
                        expect(butGot).to(equal(1))
                    default: fail("wrong error")
                    }
                })
            }
        }
    }
}
