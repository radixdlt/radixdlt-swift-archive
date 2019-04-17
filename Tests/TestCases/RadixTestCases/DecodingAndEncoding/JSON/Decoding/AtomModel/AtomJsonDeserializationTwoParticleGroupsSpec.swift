//
//  AtomJsonDeserializationTwoParticleGroupsSpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class AtomJsonDeserializationTwoParticleGroupsSpec: QuickSpec {
        
    override func spec() {
        /// Scenario 3
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - Non trivial Atom") {
            let atom: Atom = model(from: jsonForAtomWith2ParticleGroups)
            describe("Its non empty Signature") {
                let signature = atom.signatures["71c3c2fc9fee73b13cad082800a6d0de"]!
                it("should contain a BigInteger r") {
                    expect(signature.r).to(equal(BigUnsignedInt(hex: "25150b1a4996cf1571d00b4ef0d62667402a6e2ea11bf563e867a80774ef1c05")))
                }
            }
            describe("Its non empty metadata") {
                let metaData = atom.metaData
                it("Should have a valid timestamp") {
                    expect(metaData.timestamp).to(beNotNil())
                }
            }
            describe("Its non empty ParticleGroup") {
                describe("The ParticleGroup's TokenDefinitionParticle") {
                    let tokenDefinitionParticle = atom.particleGroups.firstParticle(ofType: TokenDefinitionParticle.self)!
                    
                    it("has a name") {
                        expect(tokenDefinitionParticle.name).to(equal("Cyon"))
                    }
                    
                    it("has a symbol") {
                        expect(tokenDefinitionParticle.symbol).to(equal("CCC"))
                    }
                    
                    it("has a description") {
                        expect(tokenDefinitionParticle.description).to(equal("Cyon Crypto Coin is the worst shit coin"))
                    }
                    
                    describe("Its non-empty metadata") {
                        let metaData = tokenDefinitionParticle.metaData
                        it("contains two values") {
                            expect(metaData).to(haveCount(2))
                        }
                    }
                }
                describe("The ParticleGroup's UniqueParticle") {
                    let uniqueParticle = atom.particleGroups.firstParticle(ofType: UniqueParticle.self)!
                    
                    it("has a name") {
                        expect(uniqueParticle.name).to(equal("Sajjon"))
                    }
                    
                    it("has an address") {
                        expect(uniqueParticle.address).to(equal("JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"))
                    }
                 
                }
                describe("The ParticleGroup's MessageParticke") {
                    let messsageParticle = atom.particleGroups.firstParticle(ofType: MessageParticle.self)!
                    
                    it("Its payload is a text message to us") {
                        expect(messsageParticle.textMessage).to(equal("Hello Radix!"))
                    }
                }
            }
        }
    }
}

let jsonForAtomWith2ParticleGroups = """
{
    "\(RadixModelType.jsonKey)": \(RadixModelType.atom.serializerId),
    "signatures": {
        "71c3c2fc9fee73b13cad082800a6d0de":{
            "\(RadixModelType.jsonKey)": \(RadixModelType.signature.serializerId),
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
            "\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.serializerId),
            "metaData": {
                "timestamp": ":str:1546300800",
            },
            "particles": [
                {
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.serializerId),
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": \(RadixModelType.tokenDefinitionParticle.serializerId),
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
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.serializerId),
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": \(RadixModelType.uniqueParticle.serializerId),
                        "name": ":str:Sajjon",
                        "address": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
                    }
                }
            ]
        },
        {
            "\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.serializerId),
            "metaData": {
                "timestamp": ":str:1546300800",
            },
            "particles": [
                {
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.serializerId),
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": \(RadixModelType.unallocatedTokensParticle.serializerId),
                        "granularity": ":u20:1",
                        "nonce": 992284943125945,
                        "permissions": {
                            "mint": ":str:token_creation_only",
                            "burn": ":str:none"
                        },
                        "amount": ":u20:1000000000000000000000000000",
                        "tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
                    }
                },
                {
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.serializerId),
	                "spin": 1,
					"particle": {
						"\(RadixModelType.jsonKey)": \(RadixModelType.messageParticle.serializerId),
						"to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
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