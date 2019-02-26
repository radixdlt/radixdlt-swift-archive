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
            let atom: Atom = model(from: json)
            describe("Its non empty Signature") {
                let signature = atom.signatures["71c3c2fc9fee73b13cad082800a6d0de"]!
                it("should contain a BigInteger r") {
                    expect(signature.r).to(equal(BigUnsignedInt(hex: "94542c69265b3c55c7402d3bc358999d00a9b8ba846fd58fa19ea01dd3bc7017")))
                }
            }
            describe("Its non empty ParticleGroup") {
                let particleGroup = atom.particleGroups[0]
                it("should contain a TokenDefinitionParticle") {
                    expect(particleGroup[0].particle).to(beAKindOf(TokenDefinitionParticle.self))
                }
                describe("The ParticleGroup's TokenDefinitionParticle") {
                    let tokenDefinitionParticle = particleGroup[0].particle as! TokenDefinitionParticle
                    
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
            }
        }
    }
}

private let json = """
{
    "signatures": {
        "71c3c2fc9fee73b13cad082800a6d0de":{
            "r":":byt:AJRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX",
            "s":":byt:AKbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H"
        }
    },
    "metaData": {},
    "particleGroups": [
        {
            "metaData": {},
            "particles": [
                {
                    "spin": 1,
                    "particle": {
                        "type": "tokenDefinition",
                        "symbol": ":str:CCC",
                        "name": ":str:Cyon",
                        "description": ":str:Cyon Crypto Coin is the worst shit coin",
                        "metaData": {
                            "foo": ":str:bar",
                            "bar": ":str:buz"
                        },
                        "granularity": ":u20:1",
                        "permissions": {
                            "burn": ":str:none",
                            "mint": ":str:pow",
                            "transfer": ":str:none"
                        },
                        "address": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
                    }
                }
            ]
        },
        {
            "metaData": {},
            "particles": [
                {
                    "spin": 1,
                    "particle": {
                        "type": "mintedToken",
                        "owner": ":byt:A3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9o",
                        "receiver": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "nonce": 992284943125945,
                        "planck": 24805440,
                        "amount": ":u20:1000000000000000000000000000",
                        "token_reference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
                    }
                }
            ]
        }
    ]
}
"""
