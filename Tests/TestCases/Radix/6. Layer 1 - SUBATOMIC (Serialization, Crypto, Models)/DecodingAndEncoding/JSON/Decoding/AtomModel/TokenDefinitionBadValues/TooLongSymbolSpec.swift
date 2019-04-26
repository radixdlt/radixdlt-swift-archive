//
//  AtomJsonDeserializationTokenDefinitionSymbolTooLongSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class TooLongSymbolTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingSymbolTooLong() {
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .symbol, with: ":str:01234567890123456")
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.tooManyCharacters(expectedAtMost: 14, butGot: 17),
            "Decoding should fail to deserialize JSON with a too long symbol"
        )
    }
}
