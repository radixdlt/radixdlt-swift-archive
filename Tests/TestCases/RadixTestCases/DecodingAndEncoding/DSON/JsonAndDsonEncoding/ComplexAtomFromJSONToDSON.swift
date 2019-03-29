//
//  ComplexAtomFromJSONToDSON.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Quick
import Nimble

// Commented out since Atom model is unstable and thus dson and hashes changes frequently

//class ComplexAtomFromJSONToDSONSpec: QuickSpec {
//    override func spec() {
//        let atom: Atom = model(from: atomJson)
//
//        describe("Hash Id (EUID)") {
//            it("should match Java") {
//                expect(atom.hashId).to(equal("9d9ef63575f1f185a862d753b3f2d6ac"))
//            }
//        }
//    }
//}

private let atomJson = """
{
    "metaData": {
        "timestamp": ":str:1488326400000"
    },
    "particleGroups": [
        {
            "particles": [
                {
                    "particle": {
                        "bytes": ":byt:UmFkaXguLi4ganVzdCBpbWFnaW5lIQ==",
                        "from": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "\(RadixModelType.jsonKey)": \(RadixModelType.messageParticle.serializerId),
                        "to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "\(jsonKeyVersion)": \(serializerVersion)
                    },
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.serializerId),
                    "spin": 1,
                    "\(jsonKeyVersion)": \(serializerVersion)
                }
            ],
            "\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.serializerId),
            "\(jsonKeyVersion)": \(serializerVersion)
        },
        {
            "particles": [
                {
                    "particle": {
                        "address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "amount": ":u20:1000000000000000000000000000",
                        "granularity": ":u20:1",
                        "nonce": 698107847399721,
                        "planck": 24805440,
                        "\(RadixModelType.jsonKey)": \(RadixModelType.mintedTokensParticle.serializerId),
                        "tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD",
                        "\(jsonKeyVersion)": \(serializerVersion)
                    },
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.serializerId),
                    "spin": 1,
                    "\(jsonKeyVersion)": \(serializerVersion)
                },
                {
                    "particle": {
                        "symbol": ":str:POW",
                        "address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
                        "granularity": ":u20:1",
                        "permissions": {
                            "burn": ":str:none",
                            "mint": ":str:none"
                        },
                        "name": ":str:Proof of Work",
                        "\(RadixModelType.jsonKey)": \(RadixModelType.tokenDefinitionParticle.serializerId),
                        "description": ":str:Radix POW",
                        "\(jsonKeyVersion)": \(serializerVersion)
                    },
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.serializerId),
                    "spin": 1,
                    "\(jsonKeyVersion)": \(serializerVersion)
                }
            ],
            "\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.serializerId),
            "\(jsonKeyVersion)": \(serializerVersion)
        }
    ],
    "\(RadixModelType.jsonKey)": \(RadixModelType.atom.serializerId),
    "signatures": {
        "71c3c2fc9fee73b13cad082800a6d0de": {
            "r":":byt:JRULGkmWzxVx0AtO8NYmZ0Aqbi6hG/Vj6GeoB3TvHAX=",
            "s":":byt:KbKCyHw9GYP6EyjbyQackXtF4Hj7CgX2fmTltg5VX9H=",
            "\(RadixModelType.jsonKey)": \(RadixModelType.signature.serializerId),
            "\(jsonKeyVersion)": \(serializerVersion)
        }
    },
    "\(jsonKeyVersion)": \(serializerVersion)
}
"""
