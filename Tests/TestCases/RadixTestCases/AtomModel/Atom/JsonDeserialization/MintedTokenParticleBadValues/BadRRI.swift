//
//  BadRRI
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class BadRRI: AtomJsonDeserializationMintedTokenBadValuesSpec {
    override func spec() {
        /// Scenario 15
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - MintedTokenParticle: bad RadixResourceIdentifier") {
            let badJson = self.replaceValueInParticle(for: "token_reference", with: ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/foobar/XRD")
            
            it("should fail to deserialize JSON with a MintedTokenParticle with") {
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as ResourceIdentifier.Error {
                    switch error {
                    case .unsupportedResourceType(let got):
                        expect(got).to(equal("foobar"))
                    default: fail("wrong error")
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
    }
}
