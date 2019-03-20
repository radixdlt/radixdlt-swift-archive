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
    "metaData": {
        "timestamp": ":str:1488326400000"
    }
}
"""
        /// Scenario 1
        /// https://radixdlt.atlassian.net/browse/RLAU-567
        describe("JSON deserialization - Trivial Atom") {
            let atom: Atom = model(from: json)
            
            it("should contain empty Signatures") {
                expect(atom.signatures).to(beEmpty())
            }
            
            it("should contain empty ParticleGroups") {
                expect(atom.particleGroups).to(beEmpty())
            }
        }
    }
}


