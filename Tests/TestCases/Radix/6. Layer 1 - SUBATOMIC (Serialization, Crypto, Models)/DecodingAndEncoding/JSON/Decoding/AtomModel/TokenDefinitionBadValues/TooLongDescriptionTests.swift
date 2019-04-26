//
//  TooLongDescriptionSpec
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class TooLongDescriptionTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingDescriptionTooLong() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .description, with: ":str:Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed suscipit metus sit amet nulla facilisis condimentum. Nullam at risus ante. Praesent tortor nisl, volutpat eget magna quis, fermentum. 12345!")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.tooManyCharacters(expectedAtMost: 200, butGot: 201),
            "Decoding should fail to deserialize JSON with a too long descruption"
        )
    }
}
