//
//  GranularityNegativeSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class GranularityNegativeSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        describe("JSON deserialization - TokenDefinitionParticle: negative granularity") {
            let badJson = self.replaceValueInParticle(for: .granularity, with: ":u20:-1")
            
            it("should fail to deserialize JSON with negative granulariy") {
                do {
                    try decode(Atom.self, from: badJson)
                    fail("Should not be able to decode invalid JSON")
                } catch let error as Granularity.Error {
                    switch error {
                    case .failedToCreateBigInt(let negativeAmountString):
                        expect(negativeAmountString).to(equal("-1"))
                    }
                } catch {
                    fail("Wrong error type, got: \(error)")
                }
            }
        }
    }
}
