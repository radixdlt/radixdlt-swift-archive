//
//  PublicKey+EllipticCurve.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

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
