//
//  AddressInvalidChecksumSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//


@testable import RadixSDK
import XCTest

class AddressInvalidChecksumTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingAddressInvalidChecksum() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .address, with: ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCea")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            Address.Error.checksumMismatch,
            "Decoding should fail to deserialize JSON with an invalid checksum in address"
        )
    }
}
