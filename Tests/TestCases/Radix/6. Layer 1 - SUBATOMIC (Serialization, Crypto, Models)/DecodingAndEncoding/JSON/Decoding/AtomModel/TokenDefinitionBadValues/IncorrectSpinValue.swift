//
//  IncorrectSpinValue
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class IncorrectSpinValueTests: AtomJsonDeserializationChangeJson {
    
    func testDsonDecodingSpinValueInvalid() {
        // GIVEN
        let badJson = self.replaceSpinForSpunParticle(spin: 2)

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            DecodingError.dataCorrupted(description: "Cannot initialize Spin from invalid Int value 2"),
            "Decoding should fail to deserialize JSON with a too short name"
        )
    }
}
