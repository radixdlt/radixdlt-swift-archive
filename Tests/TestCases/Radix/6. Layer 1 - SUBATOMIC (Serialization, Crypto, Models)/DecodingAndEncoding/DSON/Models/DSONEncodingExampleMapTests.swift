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

@testable import RadixSDK
import XCTest

/// DSON encoding of example map from: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
class DSONEncodingExampleMapTests: XCTestCase {
    
    func testDsonEncodingOfSimpleMap() {
        // GIVEN
        // An simple map
        let exampleMap = ExampleMap()
        
        // WHEN
        // I try to DSON encode it
        guard let dsonHex = dsonHexStringOrFail(exampleMap) else { return }
        
        // THEN
        // It should equal the expected result of "Radix Type" `map`, the table in the link provided above
        XCTAssertEqual(dsonHex, "bf616101616202ff")
    }
}

private struct ExampleMap: RadixCodable {
    let a: Int = 1
    let b: Int = 2
    
    public enum CodingKeys: String, CodingKey {
        case a
        case b
    }
    
    public var preProcess: Process {
        return { values, _ in return values }
    }
    
    public func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .a, value: a),
            EncodableKeyValue(key: .b, value: b)
        ]
    }
}
