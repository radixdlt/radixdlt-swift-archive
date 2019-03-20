//
//  TooLongNameSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class TooLongNameSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 7
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: too long name") {
            let badJson = self.replaceValueInParticle(for: .name, with: ":str:Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed 123!")
            
            it("should fail to deserialize JSON with too long name") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(errorType: InvalidStringError.self) {
                    switch $0 {
                    case .tooManyCharacters(let expectedAtMost, let butGot):
                        expect(expectedAtMost).to(equal(64))
                        expect(butGot).to(equal(65))
                    default: fail("wrong error")
                    }
                })
            }
        }
    }
}
