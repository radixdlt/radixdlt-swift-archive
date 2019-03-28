//
//  TooLongDescriptionSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class TooLongDescriptionSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 9
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: too long description") {
            let badJson = self.replaceValueInParticle(for: .description, with: ":str:Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed suscipit metus sit amet nulla facilisis condimentum. Nullam at risus ante. Praesent tortor nisl, volutpat eget magna quis, fermentum. 12345!")
            
            it("should fail to deserialize JSON with a too long description") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(errorType: InvalidStringError.self) {
                    switch $0 {
                    case .tooManyCharacters(let expectedAtMost, let butGot):
                        expect(expectedAtMost).to(equal(200))
                        expect(butGot).to(equal(201))
                    default: fail("wrong error")
                    }
                })
            }
        }
    }
}
