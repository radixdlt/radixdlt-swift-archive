//
//  IntRoundingTests.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class IntRoundingTests: XCTestCase {
    func testRounding() {
        func round(_ value: Int) -> Int {
            return value.roundedDown(toMultipleOf: 8)
        }
        
        XCTAssertEqual(0, round(1))
        XCTAssertEqual(0, round(2))
        XCTAssertEqual(0, round(6))
        XCTAssertEqual(0, round(7))
        XCTAssertEqual(8, round(8))
        XCTAssertEqual(8, round(9))
        XCTAssertEqual(8, round(15))
        XCTAssertEqual(16, round(16))
        XCTAssertEqual(16, round(17))
    }
    
    func testRoundingUp() {
        func round(_ value: Int) -> Int {
            return value.roundedDown(toMultipleOf: 8) + 8
        }
        
        XCTAssertEqual(8, round(1))
        XCTAssertEqual(8, round(2))
        XCTAssertEqual(8, round(6))
        XCTAssertEqual(8, round(7))
        XCTAssertEqual(16, round(8))
        XCTAssertEqual(16, round(9))
        XCTAssertEqual(16, round(15))
        XCTAssertEqual(24, round(16))
        XCTAssertEqual(24, round(17))
    }
    
    func testRounding3() {
        func foo(_ value: Int) -> Int {
            return value + 8 - 2*(value % 8)
        }
        XCTAssertEqual(7, foo(1))
        XCTAssertEqual(6, foo(2))
        XCTAssertEqual(5, foo(3))
        XCTAssertEqual(4, foo(4))
        XCTAssertEqual(3, foo(5))
        XCTAssertEqual(2, foo(6))
        XCTAssertEqual(1, foo(7))
        XCTAssertEqual(16, foo(8))
        XCTAssertEqual(15, foo(9))
        XCTAssertEqual(14, foo(10))
        XCTAssertEqual(13, foo(11))
        XCTAssertEqual(12, foo(12))
        XCTAssertEqual(11, foo(13))
        XCTAssertEqual(10, foo(14))
        XCTAssertEqual(9, foo(15))
        XCTAssertEqual(24, foo(16))
        XCTAssertEqual(23, foo(17))
        XCTAssertEqual(22, foo(18))
        XCTAssertEqual(21, foo(19))
        XCTAssertEqual(20, foo(20))
        XCTAssertEqual(19, foo(21))
        XCTAssertEqual(18, foo(22))
        XCTAssertEqual(17, foo(23))
        XCTAssertEqual(32, foo(24))
        XCTAssertEqual(31, foo(25))
        XCTAssertEqual(30, foo(26))
    }
    
    func testBitArray() {
        var bitArray = BitArray(repeating: true, count: 4)
        bitArray.replace(0...2, withBit: false)
        XCTAssertEqual(bitArray, [false, false, false, true])
    }
    
    func testBitArray2() {
        var bitArray = BitArray(repeating: true, count: 4)
        bitArray.replace(0..<2, withBit: false)
        XCTAssertEqual(bitArray, [false, false, true, true])
    }
    
    func testApa() {

        func apa(_ leading: Int, _ bitCount: Int) -> String {
            var bitArray = BitArray(repeating: .one, count: bitCount)
            for index in 0..<leading {
                bitArray[index] = .zero
            }
            return bitArray.hex
        }
        
        XCTAssertEqual("7fff", apa(1, 16))
        XCTAssertEqual("3fff", apa(2, 16))
        XCTAssertEqual("1fff", apa(3, 16))
        XCTAssertEqual("0fff", apa(4, 16))
        XCTAssertEqual("07ff", apa(5, 16))
        XCTAssertEqual("03ff", apa(6, 16))
        XCTAssertEqual("01ff", apa(7, 16))
        XCTAssertEqual("00ff", apa(8, 16))
        XCTAssertEqual("007f", apa(9, 16))
        XCTAssertEqual("003f", apa(10, 16))
        XCTAssertEqual("001f", apa(11, 16)) //              5 => 31  d=16
        XCTAssertEqual("000f", apa(12, 16)) //              4 => 15  d=8
        XCTAssertEqual("0007", apa(13, 16)) // 00000000             3 => 7   d=4
        XCTAssertEqual("0003", apa(14, 16)) // 0000000000000111     h: 2 -> 3   d=2
        XCTAssertEqual("0001", apa(15, 16)) // 0000000000000001     h: 1 => 1
        XCTAssertEqual("0000ffff", apa(16, 32))
    }
}
