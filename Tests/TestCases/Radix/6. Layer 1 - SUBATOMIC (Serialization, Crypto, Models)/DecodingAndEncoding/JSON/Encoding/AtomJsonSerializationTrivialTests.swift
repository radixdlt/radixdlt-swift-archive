//
//  AtomJsonSerializationTrivialTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class AtomJsonSerializationTrivialTests: XCTestCase {
    
    func testJsonEncodingAndDecodingResultsInTheSameTrivialAtom() {

        // GIVEN
        // A simple atom
        let atom: Atom = [
            UniqueParticle(
                address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
                uniqueName: "Sajjon"
            ).withSpin(.up).wrapInGroup()
        ]
        
        // WHEN
        // I JSON encode said Atom
        guard let jsonString = jsonStringOrFail(atom) else { return }
        // and JSON decode said JSON into an Atom again
        guard let atomFromJson = decodeOrFail(jsonString: jsonString, to: Atom.self) else { return}
        
        // THEN
        // The two atoms equals each other
        XCTAssertEqual(atomFromJson, atom)
        
    }
}
