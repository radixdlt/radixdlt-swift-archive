//
//  AtomJsonDeserializationInvalidJsonKeyTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class AtomJsonDeserializationInvalidJsonKeyTests: XCTestCase {
    
    func testJsonDecodingIncorrectJsonKey() {
        // GIVEN
        let badJson = jsonWithIncorrectJsonKey
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try JSON decoding
            try decode(Atom.self, jsonString: badJson),
            // THEN
            DecodingError.keyNotFound(Atom.CodingKeys.metaData),
            "I should see an error amount missing JSON key"
        )
    }
}

private let jsonWithIncorrectJsonKey = """
{
    "\(RadixModelType.jsonKey)": "\(RadixModelType.atom.serializerId)",
    "signatures": {},
    "⚠️meta⚠️Data⚠️": {}
}
"""
