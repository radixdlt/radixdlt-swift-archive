//
//  AtomJsonDeserializationInvalidSerializerValueSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class AtomJsonDeserializationInvalidSerializerValueSpec: QuickSpec {
    
    override func spec() {
        describe("JSON deserialization - Incorrect serializer value at top level") {
            it("should fail with decoding error") {
                expect { try decode(Atom.self, from: json) }.to(throwError(AtomModelDecodingError.jsonDecodingErrorTypeMismatch(expectedType: RadixModelType.atom, butGot: .signature)))
            }
        }
    }
}

private let json = """
{
    "\(RadixModelType.jsonKey)": \(RadixModelType.signature.rawValue),
    "signatures": {},
    "metaData": {},
    "particleGroups": [
        {
            "\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.rawValue),
            "particles": [],
            "metaData": {}
        }
    ]
}
"""

