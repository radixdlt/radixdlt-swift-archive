//
//  DER.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// Data on [DER encoding][1]
///
/// [1]: https://en.wikipedia.org/wiki/X.690#DER_encoding
public struct DER:
    DataInitializable,
    MinLengthSpecifying,
    MaxLengthSpecifying,
    DataConvertible,
    Equatable {
    // swiftlint:enable colon
    
    private let derEncodedData: Data
    public static let minLength = 68
    public static let maxLength = 71
    
    public init(data: Data) throws {
        try DER.validateMaxLength(of: data)
        try DER.validateMinLength(of: data)
        self.derEncodedData = data
    }
    
    public init(signature: Signature) {
        
        let byteCount: (DataConvertible) -> Data = {
            return $0.length.evenNumberedBytes
        }
        
        let encode: (Signature.Part) -> Data = {
            let numberBytes = $0.bytes
            var bytes = [Byte]()
            if numberBytes[0] > 0x7f {
                bytes = [0x0] + numberBytes
            } else {
                bytes = numberBytes
            }
            return DERDecoder.DERCode.integerCode.encodableData + byteCount(bytes) + bytes
        }
        let rAndsEncoded: DataConvertible = encode(signature.r) + encode(signature.s)
        let derEncodedData = DERDecoder.DERCode.sequenceCode.encodableData + byteCount(rAndsEncoded) + rAndsEncoded
        self.derEncodedData = derEncodedData
    }
}

// MARK: - Methods
public extension DER {
    func decoded() -> Data {
        return DERDecoder.decodeData(derEncodedData)
    }
}

// MARK: - DataConvertible
public extension DER {
    var asData: Data {
        return derEncodedData
    }
}

public protocol DERConvertible {
    func toDER() throws -> DER
}

public protocol DERInitializable {
    init(der: DER) throws
}
