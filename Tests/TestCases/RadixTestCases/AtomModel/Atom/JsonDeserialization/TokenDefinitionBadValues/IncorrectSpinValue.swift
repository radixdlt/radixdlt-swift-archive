//
//  IncorrectSpinValue
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class IncorrectSpinValue: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 12
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: Bad int value for spin") {
            let badJson = self.replaceSpinForSpunParticle(spin: 2)
            
            it("should fail to deserialize JSON with a particle of spin 2") {
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as DecodingError {
                    switch error {
                    case .dataCorrupted(let context):
                        expect(context.debugDescription).to(contain("Cannot initialize Spin from invalid Int value 2"))
                    default: fail("wrong error")
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
    }
}
