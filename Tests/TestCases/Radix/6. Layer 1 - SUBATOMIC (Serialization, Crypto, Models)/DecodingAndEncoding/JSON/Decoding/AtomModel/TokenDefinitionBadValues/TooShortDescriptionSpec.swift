//
//  TooShortDescriptionSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class TooShortDescriptionTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingDescriptionTooShort() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .description, with: ":str:1234567")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.tooFewCharacters(expectedAtLeast: 8, butGot: 7),
            "Decoding should fail to deserialize JSON with a too short descruption"
        )
    }
}
