//
//  EmptyAtomTests.swift
//  RadixSDKTests
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class EmptyAtomTests: XCTestCase {
    
    func testEmptyAtom() {
        let atom = Atom()
        XCTAssertTrue(atom.dataParticles().isEmpty)
        XCTAssertTrue(atom.consumables(spin: .up).isEmpty)
        XCTAssertTrue(atom.consumables(spin: .down).isEmpty)
        XCTAssertFalse(atom.radixHash.description.isEmpty)
        XCTAssertFalse(atom.hid.description.isEmpty)
        XCTAssertNil(atom.timestamp())
        XCTAssertFalse(atom.description.isEmpty)
        XCTAssertEqual(atom, Atom())
    }
}
