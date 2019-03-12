//
//  DataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DataConvertible: CustomStringConvertible, LengthMeasurable {
    var asData: Data { get }
    var bytes: [Byte] { get }
    func toData(minByteCount: Int?) -> Data
}

// MARK: - Default Implementation
public extension DataConvertible {
    func toData(minByteCount: Int? = nil) -> Data {
        return asData.toData(minByteCount: minByteCount)
    }

    var bytes: [Byte] {
        return asData.bytes
    }
}

// MARK: - LengthMeasurable
public extension DataConvertible {
    var length: Int {
        return asData.bytes.count
    }
}

// MARK: - Integer
public extension DataConvertible {
    var unsignedBigInteger: BigUnsignedInt {
        return BigUnsignedInt(asData)
    }
}

// MARK: - Base Conversion
public extension DataConvertible { 
    func toHexString(minLength: Int? = nil) -> HexString {
        // Hexadecimal characterrs takes up 16/8 = 2 byte per char
        return HexString(data: toData(minByteCount: 2 * minLength))
    }
    
    func toBase64String(minLength: Int? = nil) -> Base64String {
        // Base64 characters takes up 8 byte per char
        return Base64String(data: toData(minByteCount: 1 * minLength))
    }
    
    func toBase58String(minLength: Int? = nil) -> Base58String {
        // Base58 characters takes up 8 byte per char
        return Base58String(data: toData(minByteCount: 1 * minLength))
    }
    
    var hex: String {
        return toHexString().stringValue
    }
    
    var base58: String {
        return toBase58String().stringValue
    }
    
    var base64: String {
        return toBase64String().stringValue
    }
}

public extension HexString {
    func toHexString() -> HexString {
        return self
    }
}

public extension Base64String {
    func toBase64String() -> Base64String {
        return self
    }
}

public extension Base58String {
    func toBase58String() -> Base58String {
        return self
    }
}

func + (lhs: DataConvertible, rhs: Byte) -> Data {
    return Data(bytes: lhs.bytes + [rhs])
}

func + (lhs: Byte, rhs: DataConvertible) -> Data {
    return Data(bytes: [lhs] + rhs.bytes)
}

// MARK: - Conformance
extension Array: DataConvertible where Element == Byte {
    public var asData: Data {
        return Data(bytes: self)
    }
}
