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

class AtomJsonSerializationTrivialSpec: QuickSpec {
    
    override func spec() {
        /// Scenario 1
        /// https://radixdlt.atlassian.net/browse/RLAU-943
        describe("JSON serialization - Trivial Atom") {
            let atom = Atom(
                particleGroups: [ParticleGroup()]
            )
            
            it("should result in the appropriate trival JSON") {
                do {
                    let json = try RadixJSONEncoder(outputFormat: .prettyPrinted).encode(atom)
                    let jsonString = String(data: json, encoding: .utf8)!
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
            "particles": [],
            "metaData": {}
        }
    ]
}
"""
