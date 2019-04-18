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
                expect(atom.particlesOfType(TokenDefinitionParticle.self, spin: .up).first?.identifier.unique).to(equal("CYON"))
            }
        }
        
        describe("ECC") {
            it("should verify signatures signatures") {
                let identity = RadixIdentity(private: 1)
                expect(identity.publicKey.hex).to(equal("0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798"))
                let address = Address(magic: 0x02, publicKey: identity.publicKey)
                expect(address.hex).to(equal("020279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798404d542d"))
                expect(address.stringValue).to(equal("JF5FTU5wdsKNp4qcuFJ1aD9enPQMocJLCqvHE2ZPDjUNag8MKun"))
                let pow = ProofOfWork.work(atom: atom, magic: 123)!
                let atomWithPow = try! ProofOfWorkedAtom(atomWithoutPow: atom, proofOfWork: pow)
                let unsignedAtom = try! UnsignedAtom(atomWithPow: atomWithPow)
                let signedAtom = try! identity.sign(atom: unsignedAtom)
                
                expect(try! identity.didSign(atom: signedAtom)).to(beTrue())

            }
        }
    }
}


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
					    },
					    "name": ":str:Cyon Coin",
					    "\(RadixModelType.jsonKey)": "\(RadixModelType.tokenDefinitionParticle.serializerId)",
					    "description": ":str:Worst shit coin",
					    "\(jsonKeyVersion)": \(serializerVersion)
					},
					"\(RadixModelType.jsonKey)": "\(RadixModelType.spunParticle.serializerId)",
					"\(jsonKeyVersion)": \(serializerVersion)
				}
			],
		   	"\(RadixModelType.jsonKey)": "\(RadixModelType.particleGroup.serializerId)",
			"\(jsonKeyVersion)": \(serializerVersion)
		}
	],
	"\(RadixModelType.jsonKey)": "\(RadixModelType.atom.serializerId)",
	"\(jsonKeyVersion)": \(serializerVersion)
}
"""
