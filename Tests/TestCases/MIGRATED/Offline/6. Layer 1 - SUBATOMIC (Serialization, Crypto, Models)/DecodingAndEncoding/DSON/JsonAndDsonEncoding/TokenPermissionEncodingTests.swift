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

class TokenPermissionEncodingTests: TestCase {

    
    func testJsonEncodedIsPrefixed() {
        // GIVEN
        // TokenPermissions
        let permissions = TokenPermissions.all
        
        // WHEN
        // JSON encoding
        guard let jsonString = jsonStringOrFail(permissions) else { return }
        
        // THEN
        // The string is prefixed with ":str:"
        XCTAssertContains(jsonString, ":str:all")
    }
    
    func testDsonEncodedIsNotPrefixed() {
        // GIVEN
        // TokenPermissions
        let permissions = TokenPermissions.all
        
        // WHEN
        // DSON encoding
        guard let dsonHex = dsonHexStringOrFail(permissions, output: .all) else { return }
        
        // THEN
        // The string is not prefixed with ":str:"
        XCTAssertNotContains(dsonHex, ":str:all")
        // ... but contains DSON hex for "burn" and "all"
        XCTAssertContains(
            dsonHex,
             ["burn", "all"].compactMap { dsonHexStringOrFail($0, output: .all) }.joined()
        )
    }
}

