//
//  PublicKey.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct PublicKey: PrefixedJsonDecodableByProxy, Hashable, DataConvertible {
    public let data: Data
    public init(data: Data) {
        self.data = data
    }
}

// MARK: - Convenience init
public extension PublicKey {
    init(private privateKey: PrivateKey) {
        implementMe
    }
    
    init(hexString: HexString) throws {
        self.init(data: hexString.asData)
    }
    
    init(base64: Base64String) throws {
        self.init(data: base64.asData)
    }
}

// MARK: - PrefixedJsonDecodableByProxy
public extension PublicKey {
    init(proxy: Base64String) throws {
        try self.init(base64: proxy)
    }
}

// MARK: - StringInitializable
public extension PublicKey {
    init(string: String) throws {
        let base64 = try Base64String(string: string)
        try self.init(base64: base64)
    }
}

// MARK: - PrefixedJsonDecodable
public extension PublicKey {
    static let jsonPrefix = JSONPrefix.bytesBase64
    init(from: Base64String) throws {
        self.init(data: from.asData)
    }
}

// MARK: - DataConvertible
public extension PublicKey {
    var asData: Data { return data }
}

// MARK: - CustomStringConvertible
public extension PublicKey {
    var description: String {
        return hex
    }
}

public extension BigSignedInt {
    public init(data: Data) {
        let hex = data.toHexString()
        guard let bigInt = BigSignedInt(hex, radix: 16) else {
            incorrectImplementation("Should always be able to create from hex")
        }
        self = bigInt
    }
}

public struct EllipticCurvePoint {
    public typealias Scalar = BigSignedInt
    public let x: Scalar
    public let y: Scalar
}

internal let bitsPerByte = 8

public extension PublicKey {
    public enum Format {
        case compressed
        case uncompressed(isHybrid: Bool)
        
        init(byte: Byte) {
            switch byte {
            case 2, 3: self = .compressed
            case 4: self = .uncompressed(isHybrid: false)
            case 6, 7: self = .uncompressed(isHybrid: true)
            default: incorrectImplementation("Bad format")
            }
        }
    }
    
    var format: Format {
        return Format(byte: data[0])
    }
    
    func toBase64String() -> Base64String {
        return Base64String(data: data)
    }
    
    func toHexString() -> HexString {
        return HexString(data: data)
    }
    
    public enum DecodePointError: Swift.Error {
        case compressedKeyTooShort(expected: Int, butGot: Int)
    }
    
    // swiftlint:disable:next function_body_length
    public static func pointOnCurveFromKey(data: Data) throws -> EllipticCurvePoint {
        let expectedBytecount = 128
        let formatByte = data[0]
        let format = Format(byte: formatByte)
        let key = data.dropFirst()
        let x = EllipticCurvePoint.Scalar(data: key)
        var y: EllipticCurvePoint.Scalar!
        let byteCount = key.count
        switch format {
        case .compressed:
            guard byteCount == expectedBytecount else {
                throw DecodePointError.compressedKeyTooShort(expected: expectedBytecount, butGot: byteCount)
            }
//            y = decompressPoint(yTilde: formatByte & Byte(1), x: x)
        case .uncompressed(let isHybrid):
            let expectedByteCountUncompressed = 2 * expectedBytecount
            guard byteCount == expectedByteCountUncompressed else {
                throw DecodePointError.compressedKeyTooShort(expected: expectedByteCountUncompressed, butGot: byteCount)
            }
            y = EllipticCurvePoint.Scalar(data: key.suffix(expectedBytecount))
            if isHybrid {
                // validate y coordinate for hybrid
            }
        }
        return EllipticCurvePoint(x: x, y: y)
    }
}
