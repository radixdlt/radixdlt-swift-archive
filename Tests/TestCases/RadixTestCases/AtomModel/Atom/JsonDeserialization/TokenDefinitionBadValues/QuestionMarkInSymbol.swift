//
//  QuestionMarkInSymbolSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class QuestionMarkInSymbolSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 6
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: Symbol bad chars") {
            let badJson = self.replaceValueInParticle(for: "symbol", with: ":str:BAD?")
            
            it("should fail to deserialize JSON with empty symbol") {
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as InvalidStringError {
                    switch error {
                    case .invalidCharacters(let expectedCharacters, let butGot):
                        expect(expectedCharacters).to(equal(CharacterSet.numbersAndUppercaseAtoZ))
                        expect(butGot).to(equal("?"))
                    default: fail("wrong error")
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
    }
}
