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

import XCTest
@testable import RadixSDK

class HashTests: XCTestCase {

    func testSha256Twice() {
        let data = "Hello Radix".toData()
        let hasher = Sha256Hasher()
        let singleHash = hasher.hash(data: data)
        let twice = hasher.hash(data: singleHash)
        let double = Sha256TwiceHasher().hash(data: data)
        XCTAssertEqual(double, twice)
        XCTAssertEqual(singleHash.hex, "374d9dc94c1252acf828cdfb94946cf808cb112aa9760a2e6216c14b4891f934")
        XCTAssertEqual(double.hex, "fd6be8b4b12276857ac1b63594bf38c01327bd6e8ae0eb4b0c6e253563cc8cc7")
    }
    
    func testEuidLengthIsAlways16() {
        let unhashedHex: HexString = "010355c1b10e882ff9bdf8a4252afa21620e927bc9f03697dc0243670fb26e692484"
        let unhashed = unhashedHex.asData
        XCTAssertEqual(unhashed.length, 34)
        
        let radixHash = RadixHash(unhashedData: unhashed)
        XCTAssertEqual(radixHash.hex, "00709cc52cabdfb3d0fb95cbca163ad241dcd9791461d3a01f207ed93f9bdd21")
        let euid = radixHash.toEUID()
        XCTAssertEqual(euid.asData.length, EUID.byteCount)
        XCTAssertEqual(euid.hex, "00709cc52cabdfb3d0fb95cbca163ad2")
    }
}
