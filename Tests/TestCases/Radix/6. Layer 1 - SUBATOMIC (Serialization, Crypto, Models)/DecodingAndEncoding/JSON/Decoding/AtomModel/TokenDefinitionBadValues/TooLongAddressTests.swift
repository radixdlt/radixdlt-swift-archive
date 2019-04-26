//
//  TooLongAddressTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class TooLongAddressTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingTokenDefinitionParticleAddressTooLong() {
        // GIVEN
        // Json with an address with 52 chars instead of max 51
        let badJson = self.replaceValueInParticle(for: .address, with: ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCeiA")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try to decode bad json
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.tooManyCharacters(expectedAtMost: 51, butGot: 52),
            "It should fail when IP address contains > UInt8.max"
        )

    }
}
