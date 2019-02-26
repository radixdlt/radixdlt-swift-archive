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
            let badJson = self.replaceValueInParticle(for: "symbol", with: ":str:")
            it("should fail to deserialize JSON with empty symbol") {
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as PrefixedStringWithValue.Error {
                    switch error {
                    case .noValueFound: break
                    default: fail("wrong error")
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
    }
}
