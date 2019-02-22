//
//  AtomJsonDeserializationSpec.swift
//  RadixSDKTests
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK

import Nimble
import Quick


struct UnexpectedNilError: Error {}

class AtomJsonDeserializationSpec: QuickSpec {
    
    override func spec() {
        
        describe("JSON deserialization") {
            
            describe("Trivial Atom") {
                let atom: Atom = model(from: trivialAtomJson)
                it("should contain empty MetaData") {
                    expect(atom.metaData).to(beEmpty())
                }
                it("should contain empty Signatures") {
                    expect(atom.signatures).to(beEmpty())
                }
                it("should contain one single ParticleGroup") {
                    expect(atom.particleGroups).to(haveCount(1))
                    expect(atom.particleGroups).to(containElementSatisfying({ particleGroup in
                        return particleGroup.isEmpty
                    }, "which contains zero particles"))
                }
            }
            
            describe("Non trivial Atom") {
                let atom: Atom = model(from: nonTrivialAtomJson)
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
}

let trivialAtomJson = """
{
    "signatures": {},
    "metaData": {},
    "particleGroups": [
        {
            "particles": [],
            "metaData": {}
        }
    ]
}
"""

let nonTrivialAtomJson = """
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
                        "serializer": 1337,
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
        }
    ]
}
"""
