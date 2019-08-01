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

// swiftlint:disable colon opening_brace

/// Network Port represented as UInt16
public struct Port:
    CBORConvertible,
    Throwing,
    CustomStringConvertible,
    Codable,
    Hashable,
    ExpressibleByIntegerLiteral
{
    // swiftlint:enable colon opening_brace
    
    public typealias Value = UInt16
    public let port: Value
    
    public init(_ port: Value) {
        self.port = port
    }
}

public extension Port {
    init(unvalidated: Int) throws {
        guard let port = Value(exactly: unvalidated) else {
            throw Error.invalidExpectedUInt16(butGot: unvalidated)
        }
        self.init(port)
    }
}

// MARK: - Decodable
public extension Port {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(unvalidated: container.decode(Int.self))
    }
}

// MARK: - Throwing
public extension Port {
    enum Error: Swift.Error, Equatable {
        case invalidExpectedUInt16(butGot: Int)
    }
}

// MARK: - CustomStringConvertible
public extension Port {
    var description: String {
        return port.description
    }
}

// MARK: - CBORConvertible
public extension Port {
    func toCBOR() -> CBOR {
        return CBOR.int64(Int64(port))
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Port {
    init(integerLiteral value: Value) {
        self.init(value)
    }
}

// MARK: - Presets
public extension Port {
    static let localhost: Port = 8080
    static let nodeFinder: Port = 443
}
