//
//  TrivialAtomToDsonTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class AtomToDsonTests: XCTestCase {
    func testDsonEncodingOfAtom() {
        // GIVEN
        // An atom containing just timestamp
        let atom = Atom(metaData: .timestamp("1234567890123"))
        
        // WHEN
        // I DSON encode said atom
        guard let dsonHex = dsonHexStringOrFail(atom) else { return }
        
        // THEN
        // I can see that the DSON only contains metaData and not signatures, nor particlegroups
        func dson(forKey key: Atom.CodingKeys) -> String? {
            return dsonHexStringOrFail(key.rawValue, output: .all)
        }
        
        XCTAssertContains(dsonHex, dson(forKey: .metaData))
        XCTAssertNotContains(dsonHex, dson(forKey: .signatures))
        XCTAssertNotContains(dsonHex, dson(forKey: .particleGroups))
        
    }
}
