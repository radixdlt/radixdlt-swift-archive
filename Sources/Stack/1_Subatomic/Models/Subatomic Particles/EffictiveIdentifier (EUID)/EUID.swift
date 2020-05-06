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

// swiftlint:disable colon opening_brace

/// `EUID` is an abbreviation for `Extended Unique Identifier`, and holds a 128 bit int
public struct EUID:
    PrefixedJSONCodable,
    StringRepresentable,
    DataInitializable,
    CBORDataConvertible,
    ExactLengthSpecifying,
    Hashable,
    Comparable,
    CustomStringConvertible
{
    
    // swiftlint:enable colon opening_brace
    
    public typealias Value = BigUnsignedInt

    private let value: Value

    public init(data: Data) throws {
        try EUID.validateLength(of: data)
        self.value = Value(data: data)
    }
}

// MARK: - Convenience Initialisers
public extension EUID {

    init(value: Value) throws {
        try self.init(data: value.toData(minByteCount: EUID.byteCount))
    }
    
    /// If a positive integer value is passed that will be used directly, if a negative int is passed, the the two-s complement of that will be used.
    init(int: Int) throws {
        let value: Value
        if int < 0 {
            // negative values are converted using Two's complement:
            // -1 => fff...fff - 1 => fff..ffe
            // -2 => fff...fff - 2 => fff..ffd
            value = Value(data: [Byte](repeating: 0xff, count: EUID.byteCount).asData) - Value(abs(int + 1))
        } else {
            value = Value(int)
        }
        
        try self.init(value: value)
    }
}

// MARK: - Comparable
public extension EUID {
    static func < (lhs: EUID, rhs: EUID) -> Bool {
        return lhs.value < rhs.value
    }
    static func > (lhs: EUID, rhs: EUID) -> Bool {
        return lhs.value > rhs.value
    }
}

// MARK: - StringInitializable
public extension EUID {
    init(string: String) throws {
        try self.init(hex: try HexString(string: string))
    }
}

// MARK: - ExactLengthSpecifying
public extension EUID {
    static let byteCount = 16
    static var length: Int { return byteCount}
}

// MARK: - DSONPrefixSpecifying
public extension EUID {
    static var dsonPrefix: DSONPrefix {
        return .euidHex
    }
}

// MARK: - DataConvertible
public extension EUID {
    var asData: Data {
        let dataFromInt = value.toData(minByteCount: EUID.byteCount, concatMode: .prepend)
        assert(dataFromInt.length == EUID.byteCount)
        return dataFromInt
    }
}

// MARK: - StringRepresentable
public extension EUID {
    var stringValue: String {
        // Yes MUST be lower case, since DSON encoding is case sensitive
        return toHexString(case: .lower).stringValue
    }
}

// MARK: - CustomStringConvertible
public extension EUID {
    var description: String {
        return toHexString(case: .lower).value
    }
}

// MARK: - Public
public extension EUID {
        
    /// Converting the Int128 value of this EUID to a `Shard`, being the 64 most significant bits, converted to bigEndian.
    var shard: Shard {
        let halfByteCount = EUID.byteCount / 2
        
        do {
            return try Shard(data: value.asData.prefix(halfByteCount)).bigEndian
        } catch {
            incorrectImplementation("Should be able to create shard from bytes, error: \(error)")
        }
    }
}

// MARK: - PrefixedJSONDecodable
public extension EUID {
    static let jsonPrefix: JSONPrefix = .euidHex
}
