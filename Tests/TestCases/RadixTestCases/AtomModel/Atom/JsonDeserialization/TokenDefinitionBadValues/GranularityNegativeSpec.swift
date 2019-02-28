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
        /// Scenario 16
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: negative granularity") {
            let badJson = self.replaceValueInParticle(for: .granularity, with: ":u20:-1")
            
            it("should fail to deserialize JSON with negative granulariy") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(type: Granularity.Error.self) {
                    switch $0 {
                    case .failedToCreateBigInt(let negativeAmountString):
                        expect(negativeAmountString).to(equal("-1"))
                    }
                })
            }
        }
    }
}
