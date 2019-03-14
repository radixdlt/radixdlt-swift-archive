//
//  AtomJsonSerializationTrivialSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class AtomToDsonSpec: QuickSpec {
    override func spec() {
        describe("Dson encoding of trivial atom") {
            it("should not encode empty signatures and empty particle group list") {
                let atom = Atom(metaData: ["U": "3"])
                let dson = try! atom.toDSON()
                let dsonHex = dson.hex
                expect(dsonHex).to(equal("bf686d65746144617461bf61556133ff6a73657269616c697a65721a001ed1516776657273696f6e1864ff"))
                
//                expect(dsonHex).to(contain(
//                    ["burn", "all"].map { try! $0.toDSON().hex }.joined()
//                ))
                expect(dsonHex).to(contain(try! Atom.CodingKeys.metaData.rawValue.toDSON().hex))
                expect(dsonHex).toNot(contain(try! Atom.CodingKeys.signatures.rawValue.toDSON().hex))
                expect(dsonHex).toNot(contain(try! Atom.CodingKeys.particleGroups.rawValue.toDSON().hex))
            }
        }
    }
}

class AtomJsonSerializationTrivialSpec: QuickSpec {
    
    override func spec() {
        /// Scenario 1
        /// https://radixdlt.atlassian.net/browse/RLAU-943
        describe("JSON serialization - Trivial Atom") {
            let atom = Atom(
                particleGroups: [
                    ParticleGroup(spunParticles: [
                        SpunParticle(
                            spin: .up,
                            particle: UniqueParticle(
                                address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
                                uniqueName: "Sajjon"
                            )
                        )
                    ])
                ]
            )
            
            it("should result in the appropriate trival JSON") {
                do {
                    let json = try RadixJSONEncoder(outputFormat: .prettyPrinted).encode(atom)
                    let jsonString = String(data: json, encoding: .utf8)!
                    print("🎢")
                    print(jsonString)
                    print("🎢")
                    let atomFromJSON = try RadixJSONDecoder().decode(Atom.self, from: jsonString.data(using: .utf8)!)
                    expect(atomFromJSON).to(equal(atom))
                } catch {
                    fail("unexpected error: \(error)")
                }
            }
        }
        
    }
}

private let expectedJson = """
{
    "\(RadixModelType.jsonKey)": \(RadixModelType.atom.rawValue),
    "signatures": {},
    "metaData": {},
    "particleGroups": [
        {
            "\(RadixModelType.jsonKey)": \(RadixModelType.particleGroup.rawValue),
            "particles": [
                {
                    "\(RadixModelType.jsonKey)": \(RadixModelType.spunParticle.rawValue),
                    "spin": 1,
                    "particle": {
                        "\(RadixModelType.jsonKey)": \(RadixModelType.uniqueParticle.rawValue),
                        "name": ":str:Sajjon",
                        "address": ":adr:JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
                    }
                }
            ],
            "metaData": {}
        }
    ]
}
"""
