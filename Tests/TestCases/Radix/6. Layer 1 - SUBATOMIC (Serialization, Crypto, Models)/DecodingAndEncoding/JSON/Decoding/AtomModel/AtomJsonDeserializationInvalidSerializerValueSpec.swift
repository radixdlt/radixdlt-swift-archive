//
//  AtomJsonDeserializationInvalidSerializerValueSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class AtomJsonDeserializationInvalidSerializerValueTests: XCTestCase {

    func testJsonDecodingOfAtomSerializerIncorrect() {
        // GIVEN
        let badJson = invalidAtomSerializerJson
        
        XCTAssertThrowsSpecificError(
            try decode(Atom.self, jsonString: badJson),
            AtomModelDecodingError.jsonDecodingErrorTypeMismatch(expectedSerializer: RadixModelType.atom, butGot: .signature),
            "JSON decoding should fail with when serializer for Atom is incorrect"
        )
    }
}

private let invalidAtomSerializerJson = """
{
    "\(RadixModelType.jsonKey)": "\(RadixModelType.signature.serializerId)",
    "signatures": {},
    "metaData": {
        "timestamp": ":str:1488326400000"
    },
    "particleGroups": [
        {
            "\(RadixModelType.jsonKey)": "\(RadixModelType.particleGroup.serializerId)",
            "particles": [],
            "metaData": {}
        }
    ]
}
"""
