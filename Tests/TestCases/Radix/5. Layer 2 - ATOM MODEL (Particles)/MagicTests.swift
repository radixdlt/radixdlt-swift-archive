/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

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
