//
//  AtomJsonDeserializationInvalidJsonKeySpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class AtomJsonDeserializationInvalidJsonKeySpec: QuickSpec {
    
    override func spec() {
        /// Scenario 2
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - Incorrect JSON Key") {
            it("should fail with decoding error") {
                do {
                    _ = try decode(Atom.self, from: json)
                    fail("Should not be able to decode invalid JSON")
                } catch {
                    expect(error).to(beAKindOf(DecodingError.self))
                }
            }
        }
    }
}

private let json = """
{
    "signatures": {},
    "metaData": {},
    "p4rticleGroups": [
        {
            "particles": [],
            "metaData": {}
        }
    ]
}
"""
