//
//  QuestionMarkInSymbolTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class QuestionMarkInSymbolTests: AtomJsonDeserializationChangeJson {
    
    func testJsonDecodingSymbolBadChars() {
        
        // GIVEN
        let badJson = self.replaceValueInParticle(for: .symbol, with: ":str:BAD?")
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try decoding the bad json string into an Atom
            try decode(Atom.self, jsonString: badJson),
            // THEN
            InvalidStringError.invalidCharacters(expectedCharacters: CharacterSet.numbersAndUppercaseAtoZ, butGot: "?"),
            "Decoding should fail to deserialize JSON with empty symbol"
        )
    }
}
