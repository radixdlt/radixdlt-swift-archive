//
//  MagicTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-06-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class MagicTest: XCTestCase {
    func testMagicEndianess() {

        func doTest(magic: Magic, expectedHex: String) {
            let hex = magic.toFourBigEndianBytes().hex
            XCTAssertEqual(hex, expectedHex)
        }
        
        doTest(magic: 0, expectedHex: "00000000")
        doTest(magic: 1, expectedHex: "00000001")
        doTest(magic: 2, expectedHex: "00000002")
        
        doTest(magic: Magic(integerLiteral: Magic.Value.max), expectedHex: "7fffffff")
        doTest(magic: Magic(integerLiteral: Magic.Value.min), expectedHex: "80000000")
        
        
        doTest(magic: -1, expectedHex: "ffffffff")
        doTest(magic: -2, expectedHex: "fffffffe")
        
        doTest(magic: 1337, expectedHex: "00000539")
        doTest(magic: 237, expectedHex: "000000ed")
        doTest(magic: 42, expectedHex: "0000002a")
        
        doTest(magic: -1337, expectedHex: "fffffac7")
        doTest(magic: -237, expectedHex: "ffffff13")
        doTest(magic: -42, expectedHex: "ffffffd6")
    }
    
    func testDson() {
        func doTest(magic: Magic, expectedHex: String) {
            let hex = try! magic.toDSON(output: .all).hex
            XCTAssertEqual(hex, expectedHex)
        }
        
        doTest(magic: 0, expectedHex: "00")
        doTest(magic: 1, expectedHex: "01")
        doTest(magic: 2, expectedHex: "02")
        
        doTest(magic: Magic(integerLiteral: Magic.Value.max), expectedHex: "1a7fffffff")
        doTest(magic: Magic(integerLiteral: Magic.Value.min), expectedHex: "3a7fffffff")
        
        
        doTest(magic: -1, expectedHex: "20")
        doTest(magic: -2, expectedHex: "21")
        
        doTest(magic: 1337, expectedHex: "190539")
        doTest(magic: 237, expectedHex: "18ed")
        doTest(magic: 42, expectedHex: "182a")
        
        doTest(magic: -1337, expectedHex: "390538")
        doTest(magic: -237, expectedHex: "38ec")
        doTest(magic: -42, expectedHex: "3829")
    }
}
