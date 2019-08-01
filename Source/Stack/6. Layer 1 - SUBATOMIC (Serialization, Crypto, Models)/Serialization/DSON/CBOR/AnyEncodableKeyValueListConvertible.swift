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

public protocol AnyEncodableKeyValueListConvertible: DSONEncodable {
    func anyEncodableKeyValues(output: DSONOutput) throws -> [AnyEncodableKeyValue]
}

// MARK: - AnyEncodableKeyValueListConvertible
public extension EncodableKeyValueListConvertible {
    func anyEncodableKeyValues(output: DSONOutput) throws -> [AnyEncodableKeyValue] {
        return try encodableKeyValues().map { try $0.toAnyEncodableKeyValue(output: output) }
    }
}

// MARK: - DSONEncodable
public extension AnyEncodableKeyValueListConvertible {
    
    /// Radix type "map", according to this: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
    ///
    /// Format is this:
    ///
    /// ```
    /// 0xbf // encodeMapStreamStart
    /// properties.forEach { CBOREncoded(name, value) }
    /// 0xff // encodeStreamEnd
    /// ```
    ///
    func toDSON(output: DSONOutput = .default) throws -> DSON {
        var keyValues = try anyEncodableKeyValues(output: output)
        
        if let processor = self as? AnyEncodableKeyValuesProcessing {
            keyValues = try processor.process(keyValues: keyValues, output: output)
        }
        
        return [
            CBOR.encodeMapStreamStart(),
            keyValues.flatMap { $0.cborEncoded() },
            CBOR.encodeStreamEnd()
        ].flatMap { $0 }.asData
    }
}
