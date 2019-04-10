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
        describe("JSON deserialization - Incorrect serializer value for atom") {
            it("should fail with decoding error") {
                expect { try decode(Atom.self, from: invalidAtomSerializerJson) }.to(throwError(AtomModelDecodingError.jsonDecodingErrorTypeMismatch(expectedSerializer: RadixModelType.atom, butGot: .signature)))
            }
        }
        
        describe("JSON deserialization - Incorrect serializer value for TokenDefinitionParticle") {
            it("should fail with decoding error") {
                expect { try decode(Atom.self, from: invalidTokenDefinitionParticleSerializerJson) }.to(throwError(errorType: DecodingError.self))
            }
        }
    }
}

private let invalidAtomSerializerJson = """
{
    "\(RadixModelType.jsonKey)": \(RadixModelType.signature.serializerId),
    "signatures": {},
    "metaData": {},
    "particleGroups": [
        {
            "\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.serializerId),
            "particles": [],
            "metaData": {}
        }
    ]
}
"""


private let invalidTokenDefinitionParticleSerializerJson = """
{
    "\(RadixModelType.jsonKey)": \(RadixModelType.atom.serializerId),
    "signatures": {},
    "metaData": {},
    "particleGroups": [
        {
            "\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.serializerId),
            "particles": [
                {
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.serializerId),
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": \(RadixModelType.messageParticle.serializerId),
                        "symbol": ":str:BAD",
                        "name": ":str:BadCoin",
                        "description": ":str:Some TokenDefinition",
                        "metaData": {},
                        "granularity": ":u20:1",
                        "permissions": {
                            "burn": ":str:none",
                            "mint": ":str:none"
                        },
                        "address": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
                    }
                }
            ],
            "metaData": {}
        }
    ]
}
"""
