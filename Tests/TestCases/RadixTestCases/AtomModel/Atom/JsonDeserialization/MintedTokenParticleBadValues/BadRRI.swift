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
            let badJson = self.replaceValueInParticle(for: .tokenDefinitionIdentifier, with: ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/foobar/XRD")
            
            it("should fail to deserialize JSON with a MintedTokenParticle with") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(errorType: ResourceIdentifier.Error.self) {
                    switch $0 {
                    case .unsupportedResourceType(let got):
                        expect(got).to(equal("foobar"))
                    default: fail("wrong error")
                    }
                })
            }
        }
    }
}
