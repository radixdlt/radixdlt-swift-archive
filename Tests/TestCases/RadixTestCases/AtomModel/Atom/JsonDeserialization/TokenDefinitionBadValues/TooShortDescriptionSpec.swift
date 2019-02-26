//
//  TooShortDescriptionSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class TooShortDescriptionSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 10
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: too short description") {
            let badJson = self.replaceValueInParticle(for: "description", with: ":str:1234567")
            
            it("should fail to deserialize JSON with a too short description") {
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as InvalidStringError {
                    switch error {
                    case .tooFewCharacters(let expectedAtLeast, let butGot):
                        expect(expectedAtLeast).to(equal(8))
                        expect(butGot).to(equal(7))
                    default: fail("wrong error")
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
    }
}
