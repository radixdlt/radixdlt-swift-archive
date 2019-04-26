//
//  AtomJsonDeserializationTwoParticleGroupsTests.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class AtomJsonDeserializationTwoParticleGroupsTests: XCTestCase {
        
    func testJsonDecodingAtomWithTwoParticleGroups() {
        // GIVEN
        // Json for an atom
        let jsonString = jsonForAtomWith2ParticleGroups
        
        // WHEN
        // I decode said json string into an Atom
        
        guard let atom = decodeOrFail(jsonString: jsonString, to: Atom.self) else { return }
        
        // THEN
        // It has a MessageParticle
        guard let messageParticle = atom.particlesOfType(MessageParticle.self, spin: .up).first else {
            return XCTFail("Expected prescene of a MessageParticle")
        }
        XCTAssertEqual(messageParticle.textMessage, "Hello Radix!")
        
        // It has a TokenDefinitionParticle
        guard let tokenDefinitionParticle = atom.particlesOfType(TokenDefinitionParticle.self, spin: .up).first else {
            return XCTFail("Expected prescene of a TokenDefinitionParticle")
        }
        XCTAssertEqual(tokenDefinitionParticle.symbol, "CCC")
        
        
        // It has a UniqueParticle
        guard let uniqueParticle = atom.particlesOfType(UniqueParticle.self, spin: .up).first else {
            return XCTFail("Expected prescene of a UniqueParticle")
        }
        XCTAssertEqual(uniqueParticle.name, "Sajjon")
    }
}

private let jsonForAtomWith2ParticleGroups = """
{
    "\(RadixModelType.jsonKey)": "\(RadixModelType.atom.serializerId)",
    "signatures": {
        "71c3c2fc9fee73b13cad082800a6d0de":{
            "\(RadixModelType.jsonKey)": "\(RadixModelType.signature.serializerId)",
            "r":":byt:JRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX=",
            "s":":byt:KbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H="
        }
    },
    "metaData": {
        "timestamp": ":str:1546300800",
        "foo": ":str:bar"
    },
    "particleGroups": [
        {
            "\(RadixModelType.jsonKey)": "\(RadixModelType.particleGroup.serializerId)",
            "metaData": {
                "timestamp": ":str:1546300800",
            },
            "particles": [
                {
                    "\(RadixModelType.jsonKey)": "\(RadixModelType.spunParticle.serializerId)",
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": "\(RadixModelType.tokenDefinitionParticle.serializerId)",
                        "symbol": ":str:CCC",
                        "name": ":str:Cyon",
                        "description": ":str:Cyon Crypto Coin is the worst shit coin",
                        "metaData": {
                            "timestamp": ":str:1551345320000",
                            "foo": ":str:bar"
                        },
                        "granularity": ":u20:1",
                        "permissions": {
                            "burn": ":str:none",
                            "mint": ":str:\(TokenPermission.tokenCreationOnly.rawValue)"
                        },
                        "address": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
                    }
                },
                {
                    "\(RadixModelType.jsonKey)": "\(RadixModelType.spunParticle.serializerId)",
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": "\(RadixModelType.uniqueParticle.serializerId)",
                        "name": ":str:Sajjon",
                        "nonce": 528772579907706,
                        "address": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
                    }
                }
            ]
        },
        {
            "\(RadixModelType.jsonKey)": "\(RadixModelType.particleGroup.serializerId)",
            "metaData": {
                "timestamp": ":str:1546300800",
            },
            "particles": [
                {
                    "\(RadixModelType.jsonKey)": "\(RadixModelType.spunParticle.serializerId)",
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": "\(RadixModelType.unallocatedTokensParticle.serializerId)",
                        "granularity": ":u20:1",
                        "nonce": 992284943125945,
                        "permissions": {
                            "mint": ":str:token_creation_only",
                            "burn": ":str:none"
                        },
                        "amount": ":u20:1000000000000000000000000000",
                        "tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD"
                    }
                },
                {
                    "\(RadixModelType.jsonKey)": "\(RadixModelType.spunParticle.serializerId)",
	                "spin": 1,
					"particle": {
						"\(RadixModelType.jsonKey)": "\(RadixModelType.messageParticle.serializerId)",
						"to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "nonce": 528772579907706,
						"from": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
						"bytes": ":byt:SGVsbG8gUmFkaXgh",
						"metaData": {
							"timestamp": ":str:1551345320000"
						}
					}
                }
            ]
        }
    ]
}
"""
