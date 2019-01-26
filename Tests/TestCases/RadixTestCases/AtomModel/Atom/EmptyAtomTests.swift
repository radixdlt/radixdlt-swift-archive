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
//        XCTAssertEqual(atom.toDson().hex, "bf6a73657269616c697a65721a001ed1516776657273696f6e1864ff")
//        XCTAssertEqual(atom.radixHash.toHexString(), "1b1cff72cb4f79d2eb50b5fb2777d65bebb5cad146e2006f25cde7a53445ffe7")
//        XCTAssertEqual(atom.hid.toHexString(), "1b1cff72cb4f79d2eb50b5fb2777d65b")
        XCTAssertNil(atom.timestamp())
        XCTAssertFalse(atom.description.isEmpty)
        XCTAssertEqual(atom, Atom())
    }
}
