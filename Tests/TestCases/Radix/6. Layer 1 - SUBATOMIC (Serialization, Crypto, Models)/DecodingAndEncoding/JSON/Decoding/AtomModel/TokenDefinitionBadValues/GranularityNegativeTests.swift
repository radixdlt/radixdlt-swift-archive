//
//  GranularityNegativeTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class GranularityNegativeTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingGranularityNegative() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .granularity, with: ":u20:-1")
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            Granularity.Error.failedToCreateBigInt(fromString: "-1"),
            "Decoding should fail to deserialize JSON with negative granulariy"
        )
    }
}
