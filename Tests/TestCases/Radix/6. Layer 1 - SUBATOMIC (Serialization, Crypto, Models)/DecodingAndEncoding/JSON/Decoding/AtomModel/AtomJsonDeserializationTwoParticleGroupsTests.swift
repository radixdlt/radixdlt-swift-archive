//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
