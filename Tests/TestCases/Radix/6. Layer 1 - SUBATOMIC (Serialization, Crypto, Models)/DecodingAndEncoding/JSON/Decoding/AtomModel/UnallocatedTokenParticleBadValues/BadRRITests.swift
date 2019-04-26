//
//  BadRRI
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class BadRRITests: AtomJsonDeserializationUnallocatedTokenBadValuesTests {
    func testJsonDecodingRRIBad() {
        // GIVEN
        let badJson = self.replaceValueInTokenParticle(for: .tokenDefinitionReference, with: ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor")

        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            ResourceIdentifier.Error.incorrectComponentCount(expected: 2, butGot: 1),
            "Decoding should fail to deserialize JSON with an RRI without name/symbol"
        )
    }
}
