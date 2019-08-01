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

// swiftlint:disable colon

/// A seemlingly random, strict positive integer, based on current time.
public struct Planck:
    CBORConvertible,
    Codable,
    Equatable,
    CustomStringConvertible,
    ExpressibleByIntegerLiteral {
// swiftlint:enable colon
    
    public typealias Value = UInt64
    let value: Value
    
    public init() {
        let millisecondsSince1970 = Value(TimeConverter.millisecondsFrom(date: Date()))
        let msPerMinute = Value(60000)
        value = millisecondsSince1970/msPerMinute + msPerMinute
    }
}

// MARK: - CBORConvertible
public extension Planck {
    func toCBOR() -> CBOR {
        return CBOR.unsignedInt(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Planck {
    init(integerLiteral value: Value) {
        self.value = value
    }
}

// MARK: - CustomStringConvertible
public extension Planck {
    var description: String {
        return value.description
    }
}

// MARK: - Decodable
public extension Planck {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Value.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
