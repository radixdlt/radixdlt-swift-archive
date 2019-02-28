//
//  DataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DataInitializable {
    init(data: Data)
}

public extension DataInitializable {
    init(base64: Base64String) {
        self.init(data: base64.asData)
    }
    init(base58: Base58String) {
        self.init(data: base58.asData)
    }
    init(hex: HexString) {
        self.init(data: hex.asData)
    }
}

public protocol DataConvertible: CustomStringConvertible, LengthMeasurable {
    var asData: Data { get }
    func toData(minByteCount: Int?) -> Data
}

public extension DataConvertible {
    func toData(minByteCount: Int? = nil) -> Data {
       return asData.toData(minByteCount: minByteCount)
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

//public extension DataConvertible where Self == Base64String {
//    func foobar() {}
//}

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
