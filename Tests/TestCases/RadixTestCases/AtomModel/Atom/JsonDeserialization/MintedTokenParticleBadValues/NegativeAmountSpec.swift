//
//  NegativeAmountSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class NegativeAmountSpec: AtomJsonDeserializationMintedTokenBadValuesSpec {
    override func spec() {
        /// Scenario 13
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - MintedTokenParticle: negative amount") {
            let badJson = self.replaceValueInParticle(for: "amount", with: ":u20:-1")
            
            it("should fail to deserialize JSON with a MintedTokenParticle with negative amount") {
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as Amount.Error  {
                    switch error {
                    case .cannotBeNegative: break
                    default: fail("wrong error")
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
    }
}
