//
//  NegativePlanckSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class NegativePlanckSpec: AtomJsonDeserializationMintedTokenBadValuesSpec {
    override func spec() {
        /// Scenario 14
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - MintedTokenParticle: negative Planck") {
            let badJson = self.replaceValueInParticle(for: "planck", with: -1)
            
            it("should fail to deserialize JSON with a MintedTokenParticle with negative planck") {
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as DecodingError {
                    switch error {
                    case .dataCorrupted(let context):
                        expect(context.debugDescription).to(contain("Parsed JSON number <-1> does not fit in UInt64."))
                    default: fail("wrong error")
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
    }
}
