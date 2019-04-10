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

class NegativeAmountSpec: AtomJsonDeserializationUnallocatedTokenBadValuesSpec {
    override func spec() {
        /// Scenario 13
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - UnallocatedTokensParticle: negative amount") {
            let badJson = self.replaceValueInTokenParticle(for: .amount, with: ":u20:-1")
            
            it("should fail to deserialize JSON with a UnallocatedTokensParticle with negative amount") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(Amount.Error.cannotBeNegative))
            }
        }
    }
}
