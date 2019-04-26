//
//  TooLongNameSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class TooLongNameTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingNameTooLong() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .name, with: ":str:Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed 123!")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.tooManyCharacters(expectedAtMost: 64, butGot: 65),
            "Decoding should fail to deserialize JSON with a too short name"
        )
    }
}
