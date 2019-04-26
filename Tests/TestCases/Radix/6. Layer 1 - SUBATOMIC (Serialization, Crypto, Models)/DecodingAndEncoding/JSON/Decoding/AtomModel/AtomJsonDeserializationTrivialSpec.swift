//
//  AtomJsonDeserializationTrivialSpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class AtomJsonDeserializationTrivialTests: XCTestCase {
    
    func testJsonDecodingTrivialAtom() {
        // GIVEN
        // A json string for an atom with just metadata
        let jsonString = jsonStringAtomWithJustMetaData
        
        // WHEN
        // I try decoding it into an Atom
        guard let atom = decodeOrFail(jsonString: jsonString, to: Atom.self) else { return }
        
        // THEN
        // The decoded Atom should contain a MetaData timestamp
        XCTAssertEqual(
            TimeConverter.readableStringFrom(date: atom.metaData.timestamp, dateStyle: .full),
            "Wednesday, March 1, 2017"
        )
    }
}


private let jsonStringAtomWithJustMetaData = """
{
    "\(RadixModelType.jsonKey)": "\(RadixModelType.atom.serializerId)",
    "metaData": {
        "timestamp": ":str:1488326400000"
    }
}
"""
