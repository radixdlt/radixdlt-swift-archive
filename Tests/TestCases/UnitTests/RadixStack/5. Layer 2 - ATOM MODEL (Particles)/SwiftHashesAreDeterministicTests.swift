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

class SwiftHashTests: TestCase {
    
    // This Swift library has opted in for deterministic hashing using `SWIFT_DETERMINISTIC_HASHING` flag, as suggested by:
    // https://github.com/apple/swift-evolution/blob/master/proposals/0206-hashable-enhancements.md#effect-on-abi-stability
    func testHashString() {
        XCTAssertEqual("Hello Hash".hashValue, -5126095785992718058)
    }
    
    func testHashOfRRI() {
        let address: Address = "JGdYaT8VUbafwXEBSoxfitXmHvg2Xq1BhvNVi3Cxd8mNp4LazBk"
        let rri: ResourceIdentifier = "/\(address)/STABLE"
        XCTAssertEqual(rri.hashValue, -9191205457814054942)
    }
}
