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

public protocol PrefixedJsonEncodable: JSONPrefixSpecifying, Encodable {
    var prefixedString: PrefixedStringWithValue { get }
}

public extension PrefixedJsonEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(prefixedString.identifer)
    }
}

// Ugly hack to resolve "candidate exactly matches" error since RawRepresentable have a default `encode` function, and the compiler is unable to distinguish between the RawRepresentable `encode` and the PrefixedJsonCodable `encode` function.
extension RawRepresentable where Self: PrefixedJsonEncodable, Self.RawValue == String {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(prefixedString.identifer)
    }
}

public extension PrefixedJsonEncodable where Self: StringRepresentable, Self: PrefixedJsonDecodable {
    var prefixedString: PrefixedStringWithValue {
        return PrefixedStringWithValue(value: stringValue, prefix: Self.jsonPrefix)
    }
}
