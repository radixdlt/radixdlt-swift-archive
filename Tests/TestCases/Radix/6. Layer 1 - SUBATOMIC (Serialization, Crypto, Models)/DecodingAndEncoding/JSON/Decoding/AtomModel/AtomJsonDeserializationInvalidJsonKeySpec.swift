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
                expect { try decode(Atom.self, from: json) }.to(throwError(errorType: DecodingError.self))
            }
        }
    }
}

private let json = """
{
    "\(RadixModelType.jsonKey)": "\(RadixModelType.atom.serializerId)",
    "signatures": {},
    "met⚠️⚠️⚠️⚠️⚠️⚠️Data": {}
}
"""
