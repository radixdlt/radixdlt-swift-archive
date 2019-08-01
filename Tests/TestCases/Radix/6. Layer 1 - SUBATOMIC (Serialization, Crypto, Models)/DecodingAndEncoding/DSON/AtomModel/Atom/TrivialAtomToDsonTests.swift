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

class AtomToDsonTests: XCTestCase {
    func testDsonEncodingOfAtom() {
        // GIVEN
        // An atom containing just timestamp
        let atom = Atom(metaData: .timestamp("1234567890123"))
        
        // WHEN
        // I DSON encode said atom
        guard let dsonHex = dsonHexStringOrFail(atom) else { return }
        
        // THEN
        // I can see that the DSON only contains metaData and not signatures, nor particlegroups
        func dson(forKey key: Atom.CodingKeys) -> String? {
            return dsonHexStringOrFail(key.rawValue, output: .all)
        }
        
        XCTAssertContains(dsonHex, dson(forKey: .metaData))
        XCTAssertNotContains(dsonHex, dson(forKey: .signatures))
        XCTAssertNotContains(dsonHex, dson(forKey: .particleGroups))
        
    }
}
