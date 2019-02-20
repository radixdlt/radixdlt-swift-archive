//
//  AtomJsonDeserializationTests.swift
//  RadixSDKTests
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest

@testable import RadixSDK

class AtomJsonDeserializationTests: XCTestCase {
    
    var emptyAtom: Atom!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        do {
            let json = """
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
            """.data(using: .utf8)!
            emptyAtom = try JSONDecoder().decode(Atom.self, from: json)
        } catch {
            return XCTFail("Failed to create empty Atom, error: \(error)")
        }
    }

    func testEmptyAtom() {
        let atom: Atom = emptyAtom
        XCTAssertEqual(atom.particleGroups.count, 1)
        let emptyParticleGroup = atom.particleGroups[0]
        XCTAssertTrue(emptyParticleGroup.metaData.isEmpty)
        XCTAssertTrue(emptyParticleGroup.spunParticles.isEmpty)
        XCTAssertTrue(atom.metaData.isEmpty)
        XCTAssertTrue(atom.signatures.isEmpty)
    }

}
