//
//  EffectiveUserIdentifier_EUID.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension CustomStringConvertible where Self: StringRepresentable {
    var description: String {
        return stringValue
    }
}

/// EffectiveUserIdentifier
public struct EUID: PrefixedJsonCodable, StringRepresentable, DataInitializable, CBORDataConvertible, Hashable, ExpressibleByIntegerLiteral, CustomStringConvertible {
    
    public typealias Value = BigUnsignedInt
    public static let byteCount = 16

    private let value: Value

    public init(_ data: Data) throws {
        if data.count > EUID.byteCount {
            throw Error.tooManyBytes(expected: EUID.byteCount, butGot: data.count)
        }
        
        if data.count < EUID.byteCount {
            throw Error.tooFewBytes(expected: EUID.byteCount, butGot: data.count)
        }
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
        try self.init(value.toData(minByteCount: EUID.byteCount))
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
        return value.toHexString().stringValue
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
        return value.toHexString()
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
}

// MARK: - Encodable
public extension EUID {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(toHexString())
    }
}
