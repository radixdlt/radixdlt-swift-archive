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
                expect { try decode(Atom.self, from: badJson) }.to(throwError(type: DecodingError.self) {
                    switch $0 {
                    case .dataCorrupted(let context):
                        expect(context.debugDescription).to(contain("Cannot initialize Spin from invalid Int value 2"))
                    default: fail("wrong error")
                    }
                })
            }
        }
    }
}
