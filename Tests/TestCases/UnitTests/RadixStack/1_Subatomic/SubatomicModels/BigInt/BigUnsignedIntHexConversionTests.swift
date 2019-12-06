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
@testable import RadixSDK
import BigInt
import XCTest

class BigUnsignedIntTests: TestCase {
    
    func testUint256() {
        let table = [
            "10": "A",
            "100": "64",
            "1000": "3E8",
            "10000": "2710",
            "100000": "186A0",
            "1000000": "F4240",
            "10000000": "989680",
            "100000000": "5F5E100",
            "1000000000": "3B9ACA00",
            ]
        for (key, value) in table {
            let bigInt = BigUnsignedInt(stringLiteral: key)
            XCTAssertEqual(bigInt.toHexString(uppercased: true).stringValue, value)
            XCTAssertEqual(bigInt.asData.toHexString(case: .upper, mode: .trim).stringValue, value)
            XCTAssertEqual(bigInt.toBase64String().asData.toHexString(case: .upper, mode: .trim).stringValue, value)
            XCTAssertEqual(bigInt.asData.toBase64String().toHexString(case: .upper, mode: .trim).stringValue, value)
        }
        
    }
}
