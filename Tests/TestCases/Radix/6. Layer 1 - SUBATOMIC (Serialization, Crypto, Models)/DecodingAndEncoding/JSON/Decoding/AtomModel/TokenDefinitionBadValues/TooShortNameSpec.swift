//
//  TooShortNameSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class TooShortNameTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingNameTooShort() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .name, with: ":str:B")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.tooFewCharacters(expectedAtLeast: 2, butGot: 1),
            "Decoding should fail to deserialize JSON with a too short name"
        )
    }
}
