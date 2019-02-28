//
//  AddressInvalidChecksumSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//


@testable import RadixSDK
import Nimble
import Quick

class AddressInvalidChecksumSpec: AtomJsonDeserializationChangeJson {
    
    override func spec() {
        /// Scenario 19
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - TokenDefinitionParticle: invalid checksum in address") {
            let badJson = self.replaceValueInParticle(for: .address, with: ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCea")
            
            it("should fail to deserialize JSON with an invalid checksum in address") {
                expect { try decode(Atom.self, from: badJson) }.to(throwError(Address.Error.checksumMismatch))
            }
        }
    }
}
