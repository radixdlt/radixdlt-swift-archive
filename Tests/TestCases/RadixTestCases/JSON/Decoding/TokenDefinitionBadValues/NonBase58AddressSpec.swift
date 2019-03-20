//
//  NonBase58AddressSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class NonBase58AddressSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 18
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: invalid Base58 in address") {
            let badJson = self.replaceValueInParticle(for: .address, with: ":adr:J0dWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCea")
            
            it("should fail to deserialize JSON with a non base58 string as address since it contains a zero") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(errorType: InvalidStringError.self) {
                    switch $0 {
                    case .invalidCharacters(_, let butGot):
                        expect(butGot).to(equal("0"))
                    default: fail("wrong error")
                    }
                })
            }
        }
    }
}
