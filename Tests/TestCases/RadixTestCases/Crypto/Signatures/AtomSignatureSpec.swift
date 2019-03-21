//
//  AtomSignatureSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import RadixSDK

class AtomSignatureSpec: QuickSpec {
    override func spec() {
        let atom: Atom = model(from: json)
        describe("Deserialized Atom") {
            it("should deserialize into an Atom") {
                expect(atom.particles(spin: .up, type: TokenDefinitionParticle.self).first?.identifier.unique).to(equal("CYON"))
            }
        }
        describe("Radix Hash") {
            it("should match Java") {
                expect(atom.radixHash.hex).to(equal(expectedHash))
                expect(atom.signableData.hex).to(equal(expectedHash))
            }
        }
        describe("ECC") {
            it("should verify signatures from Java library") {
                let identity = RadixIdentity(private: 1)
                expect(identity.publicKey.hex).to(equal("0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"))
                let address = Address(magic: 0x02, publicKey: identity.publicKey)
                expect(address.hex).to(equal("020279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798404d542d"))
                expect(address.stringValue).to(equal("JF5FTU5wdsKNp4qcuFJ1aD9enPQMocJLCqvHE2ZPDjUNag8MKun"))
                let unsignedAtom = try! UnsignedAtom(atom)
                let signedAtom = try! identity.sign(atom: unsignedAtom)
                expect(signedAtom.signature.hex).to(equal("4228dc7cb3850cf318664997357792a126c897e91392125e2d8daa6548f1d00c5d6e3d65028568914007dde590e32bf7ec5e12230f380f62839280d34ff19e9e"))
                expect(try! identity.didSign(atom: signedAtom)).to(beTrue())

            }
        }
    }
}

private let expectedHash = "9fb46d3c4a3bbb2058de863a70281232403b126abdaf79bcb37bd43d0b9a40ab"

private let json = """
{
	"metaData": {
        "timestamp": ":str:1488326400000"
    },
	"particleGroups": [
		{
			"particles": [
				{
					"spin": 1,
					"particle": {
					    "symbol": ":str:CYON",
					    "address": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
					    "granularity": ":u20:1",
					    "permissions": {
					        "burn": ":str:all",
					        "mint": ":str:all",
					        "transfer": ":str:all"
					    },
					    "name": ":str:Cyon Coin",
					    "\(RadixModelType.jsonKey)": \(RadixModelType.tokenDefinitionParticle.rawValue),
					    "description": ":str:Worst shit coin",
					    "\(jsonKeyVersion)": \(serializerVersion)
					},
					"\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.rawValue),
					"\(jsonKeyVersion)": \(serializerVersion)
				}
			],
		   	"\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.rawValue),
			"\(jsonKeyVersion)": \(serializerVersion)
		}
	],
	"\(RadixModelType.jsonKey)": \(RadixModelType.atom.rawValue),
	"\(jsonKeyVersion)": \(serializerVersion)
}
"""
