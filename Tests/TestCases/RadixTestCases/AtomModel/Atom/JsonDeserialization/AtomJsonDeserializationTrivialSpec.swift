//
//  AtomJsonDeserializationTrivialSpec.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class AtomJsonDeserializationTrivialSpec: QuickSpec {
    
    override func spec() {
        let json = """
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
        /// Scenario 1
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - Trivial Atom") {
            let atom: Atom = model(from: json)
            
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
    }
}


