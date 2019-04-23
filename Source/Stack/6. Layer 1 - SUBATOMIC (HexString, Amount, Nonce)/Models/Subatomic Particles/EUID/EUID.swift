//
//  EUID.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// EffectiveUserIdentifier
public struct EUID:
    PrefixedJsonCodable,
    StringRepresentable,
    DataInitializable,
    CBORDataConvertible,
    ExactLengthSpecifying,
    Hashable,
    ExpressibleByIntegerLiteral,
    CustomStringConvertible {
// swiftlint:enable colon
    
    public static let length = 16
    
    public typealias Value = BigUnsignedInt

    private let value: Value

    public init(_ data: Data) throws {
        try EUID.validateLength(of: data)
        self.value = Value(data)
    }
}

// MARK: - DSONPrefixSpecifying
public extension EUID {
    var dsonPrefix: DSONPrefix {
        return .euidHex
    }
}

// MARK: - DataInitializable
public extension EUID {
    init(data: Data) {
        do {
            try self.init(data)
        } catch {
            incorrectImplementation("Bad data")
        }
    }
}

// MARK: - DataConvertible
public extension EUID {
    var asData: Data {
        return value.asData
    }
}

// MARK: - Convenience Initializers
public extension EUID {
    init(hexString: HexString) throws {
        try self.init(hexString.asData)
    }
    
    init(value: Value) throws {
        try self.init(value.toData(minByteCount: EUID.length))
    }
}

// MARK: - StringInitializable
public extension EUID {
    init(string: String) throws {
        try self.init(hexString: try HexString(string: string))
    }
}

// MARK: - StringRepresentable
public extension EUID {
    var stringValue: String {
        // Yes MUST be lower case, since DSON encoding is case sensitive
        return toHexString(case: .lower).stringValue
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension EUID {
    init(integerLiteral int: Int) {
        do {
            try self.init(value: Value(int))
        } catch {
            fatalError("Passed bad value, error: \(error)")
        }
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
    
    /// Converting to `Shard` throws away all bytes of the `value` except the low-order 64 bytes.
    var shard: Shard {
        let byteCount = 64
        let first64Bytes: Data = value.toData(minByteCount: byteCount).prefix(byteCount)
        let first64BytesInt = Value(data: first64Bytes)
        return Shard(first64BytesInt)
    }
}

// MARK: - PrefixedJsonDecodable
public extension EUID {
    static let jsonPrefix: JSONPrefix = .euidHex
}

// MARK: - Encodable
public extension EUID {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(toHexString())
    }
}
