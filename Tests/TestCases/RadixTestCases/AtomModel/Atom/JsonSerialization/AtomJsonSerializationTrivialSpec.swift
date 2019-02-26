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

//class AtomJsonSerializationTrivialSpec: QuickSpec {
//    
//    override func spec() {
//        /// Scenario 1
//        /// https://radixdlt.atlassian.net/browse/RLAU-943
//        describe("JSON serialization - Trivial Atom") {
//            let atom = Atom(particleGroups: [ParticleGroup()])
//            
//            it("should result in the appropriate trival JSON") {
//                let json = try! JSONEncoder().encode(atom)
//                let jsonString = String(data: json, encoding: .utf8)!
//
//                expect(jsonString).to(equal(expectedJson))
//            }
//        }
//    }
//}

private let expectedJson = """
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
