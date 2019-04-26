//
//  TooShortAddress.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class TooShortAddressTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingAddressTooShort() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .address, with: ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCe")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.tooFewCharacters(expectedAtLeast: 51, butGot: 50),
            "Decoding should fail to deserialize JSON with a too short address"
        )
    }
}
