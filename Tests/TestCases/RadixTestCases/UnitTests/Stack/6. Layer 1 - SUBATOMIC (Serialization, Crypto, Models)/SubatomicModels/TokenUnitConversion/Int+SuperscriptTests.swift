//
// MIT License
//
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import XCTest

@testable import RadixSDK

class SuperscriptTests: TestCase {
    func testPositiveIntegersSuperscript() {
        XCTAssertEqual(0.superscriptString(), "⁰")
        XCTAssertEqual(1.superscriptString(), "¹")
        XCTAssertEqual(2.superscriptString(), "²")
        XCTAssertEqual(3.superscriptString(), "³")
        XCTAssertEqual(4.superscriptString(), "⁴")
        XCTAssertEqual(5.superscriptString(), "⁵")
        XCTAssertEqual(6.superscriptString(), "⁶")
        XCTAssertEqual(7.superscriptString(), "⁷")
        XCTAssertEqual(8.superscriptString(), "⁸")
        XCTAssertEqual(9.superscriptString(), "⁹")
        XCTAssertEqual(10.superscriptString(), "¹⁰")
        XCTAssertEqual(11.superscriptString(), "¹¹")
        XCTAssertEqual(12.superscriptString(), "¹²")
        
        XCTAssertEqual(19.superscriptString(), "¹⁹")
        XCTAssertEqual(20.superscriptString(), "²⁰")
        XCTAssertEqual(21.superscriptString(), "²¹")
        
        XCTAssertEqual(99.superscriptString(), "⁹⁹")
        XCTAssertEqual(100.superscriptString(), "¹⁰⁰")
        XCTAssertEqual(101.superscriptString(), "¹⁰¹")
        XCTAssertEqual(102.superscriptString(), "¹⁰²")
        
        XCTAssertEqual(237.superscriptString(), "²³⁷")
        
        XCTAssertEqual(999.superscriptString(), "⁹⁹⁹")
        XCTAssertEqual(1000.superscriptString(), "¹⁰⁰⁰")
        XCTAssertEqual(1001.superscriptString(), "¹⁰⁰¹")
        
        XCTAssertEqual(1234.superscriptString(), "¹²³⁴")
        XCTAssertEqual(1337.superscriptString(), "¹³³⁷")
    }
    
    
    func testNegativeIntegersSuperscript() {
        XCTAssertEqual(Int(-1).superscriptString(), "⁻¹")
        XCTAssertEqual(Int(-2).superscriptString(), "⁻²")
        XCTAssertEqual(Int(-3).superscriptString(), "⁻³")
        XCTAssertEqual(Int(-4).superscriptString(), "⁻⁴")
        XCTAssertEqual(Int(-5).superscriptString(), "⁻⁵")
        XCTAssertEqual(Int(-6).superscriptString(), "⁻⁶")
        XCTAssertEqual(Int(-7).superscriptString(), "⁻⁷")
        XCTAssertEqual(Int(-8).superscriptString(), "⁻⁸")
        XCTAssertEqual(Int(-9).superscriptString(), "⁻⁹")
        XCTAssertEqual(Int(-10).superscriptString(), "⁻¹⁰")
        XCTAssertEqual(Int(-11).superscriptString(), "⁻¹¹")
        XCTAssertEqual(Int(-12).superscriptString(), "⁻¹²")
        
        XCTAssertEqual(Int(-19).superscriptString(), "⁻¹⁹")
        XCTAssertEqual(Int(-20).superscriptString(), "⁻²⁰")
        XCTAssertEqual(Int(-21).superscriptString(), "⁻²¹")
        
        XCTAssertEqual(Int(-99).superscriptString(), "⁻⁹⁹")
        XCTAssertEqual(Int(-100).superscriptString(), "⁻¹⁰⁰")
        XCTAssertEqual(Int(-101).superscriptString(), "⁻¹⁰¹")
        XCTAssertEqual(Int(-102).superscriptString(), "⁻¹⁰²")
        
        XCTAssertEqual(Int(-237).superscriptString(), "⁻²³⁷")
        
        XCTAssertEqual(Int(-999).superscriptString(), "⁻⁹⁹⁹")
        XCTAssertEqual(Int(-1000).superscriptString(), "⁻¹⁰⁰⁰")
        XCTAssertEqual(Int(-1001).superscriptString(), "⁻¹⁰⁰¹")
        
        XCTAssertEqual(Int(-1234).superscriptString(), "⁻¹²³⁴")
        XCTAssertEqual(Int(-1337).superscriptString(), "⁻¹³³⁷")
    }
    
}
