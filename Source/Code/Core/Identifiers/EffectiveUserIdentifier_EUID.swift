//
//  EffectiveUserIdentifier_EUID.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// EffectiveUserIdentifier
public struct EUID: PrefixedJsonDecodable, StringInitializable, Hashable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral {
    
    public typealias Value = BigUnsignedInt
    public static let byteCount = 16

    private let value: Value

    public init(data: Data) throws {
        if data.count > EUID.byteCount {
            throw Error.tooManyBytes(expected: EUID.byteCount, butGot: data.count)
        }
        
        if data.count < EUID.byteCount {
            throw Error.tooFewBytes(expected: EUID.byteCount, butGot: data.count)
        }
        self.value = Value(data)
    }
}

// MARK: - Convenience Initializers
public extension EUID {
    init(hexString: HexString) throws {
        try self.init(data: hexString.asData)
    }
    
    init(value: Value) throws {
        try self.init(data: value.toData(minByteCount: EUID.byteCount))
    }
}

// MARK: - StringInitializable
public extension EUID {
    init(string: String) throws {
        try self.init(hexString: try HexString(string: string))
    }
}

// MARK: - ExpressibleByStringLiteral
public extension EUID {
    init(stringLiteral string: String) {
        do {
            try self.init(string: string)
        } catch {
            fatalError("Passed bad string (`\(string)`), error: \(error)")
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension EUID {
    public init(integerLiteral int: Int) {
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
        return toHexString().value
    }
}

// MARK: - Public
public extension EUID {
    
    func toHexString() -> HexString {
        return HexString(data: value.toData())
    }
    
    /// Converting to `Shard` throws away all bytes of the `value` except the low-order 64 bytes.
    var shard: Shard {
        let byteCount = 64
        let first64Bytes: Data = value.toData(minByteCount: byteCount).prefix(byteCount)
        
        return first64Bytes.withUnsafeBytes { (pointer: UnsafePointer<Shard>) -> Shard in
            return pointer.pointee
        }
        
    }
}

// MARK: - PrefixedJsonDecodable
public extension EUID {
    static let jsonPrefix: JSONPrefix = .euidHex
    init(from: HexString) throws {
        try self.init(hexString: from)
    }
}

// MARK: - Encodable
public extension EUID {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(toHexString())
    }
}
