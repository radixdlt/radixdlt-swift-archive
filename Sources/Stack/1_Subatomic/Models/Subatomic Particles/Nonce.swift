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

// swiftlint:disable colon

/// A random value between [Int.min...Int.max]
public struct Nonce:
    CBORConvertible,
    CustomStringConvertible,
    Codable,
    Equatable,
    ExpressibleByIntegerLiteral {
// swiftlint:enable colon
    
    public typealias Value = Int64
    public private(set) var value: Value
    
    public init() {
        value = Int64.random(in: Value.min...Value.max)
    }
}

public extension Nonce {
    static func += (nonce: inout Nonce, increment: Value) {
        nonce.value += increment
    }
}

// MARK: - CustomStringConvertible
public extension Nonce {
    var description: String {
        return value.description
    }
}

// MARK: - CBORConvertible
public extension Nonce {
    func toCBOR() -> CBOR {
        return CBOR.int64(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Nonce {
    init(integerLiteral value: Value) {
        self.value = value
    }
}

// MARK: - Decodable
public extension Nonce {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Value.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
