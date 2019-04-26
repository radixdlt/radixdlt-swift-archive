//
//  NonBase58AddressSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class NonBase58AddressTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingInvalidBase58InAddress() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .address, with: ":adr:J?????8zD2BMW?????cKAFx1?????UqBSsq?????kkVD7?????a")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.invalidCharacters(expectedCharacters: Base58String.allowedCharacters, butGot: "?"),
            "Decoding should fail to deserialize JSON with address containing '?'"
        )
    }
}
