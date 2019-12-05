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
import XCTest

class DecodePointTests: TestCase {
    func testPointDecoding() {
        do {
            
            let expectedX = "5d21e7a118c479a007d45401bdbd06e3f9814ad5bbbbc5cec17f19029a060903"
            let expectedY = "ccfca71eff2101ad68238112e7585110e0f2c32d345225985356dc7cab8fdcc9"
            
            let privateKeyFromCompressed = try PrivateKey(wif: "L2r8WPXNgQ79rBdyxjdscd5HHr7BaD9P8Xov7NWZ9pVNw12TFSDZ")
            let publicKeyCompressed = PublicKey(private: privateKeyFromCompressed)
            XCTAssertEqual(publicKeyCompressed.hex, "03" + expectedX)
            
            let decodedFromCompressed = try EllipticCurvePoint.decodePointFromPublicKey(publicKeyCompressed)
            XCTAssertEqual(decodedFromCompressed.x.hex, expectedX)
            XCTAssertEqual(decodedFromCompressed.y.hex, expectedY)
            
        } catch {
            XCTFail("Error: \(error)")
        }
    }
}
