//
//  TooShortSymbolSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class TooShortSymbolSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 5
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: too short symbol") {
            let badJson = self.replaceValueInParticle(for: .symbol, with: ":str:")
            it("should fail to deserialize JSON with empty symbol") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(PrefixedStringWithValue.Error.noValueFound))
            }
        }
    }
}
