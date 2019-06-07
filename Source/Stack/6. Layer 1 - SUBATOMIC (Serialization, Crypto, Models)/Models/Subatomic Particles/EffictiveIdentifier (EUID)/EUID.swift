//
//  EUID.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// `EUID` is an abbreviation for `Extended Unique Identifier`, and holds a 128 bit int
public struct EUID:
    PrefixedJsonCodable,
    StringRepresentable,
    DataInitializable,
    CBORDataConvertible,
    ExactLengthSpecifying,
    Hashable,
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

// MARK: - Convenience Initializers
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
    var dsonPrefix: DSONPrefix {
        return .euidHex
    }
}

// MARK: - DataConvertible
public extension EUID {
    var asData: Data {
        return value.asData
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
    
    func toHexString() -> HexString {
        return value.toHexString()
    }
    
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

// MARK: - PrefixedJsonDecodable
public extension EUID {
    static let jsonPrefix: JSONPrefix = .euidHex
}
