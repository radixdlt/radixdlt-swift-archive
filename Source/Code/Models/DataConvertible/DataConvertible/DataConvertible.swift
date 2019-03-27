//
//  DataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import CryptoSwift

public protocol DataConvertible: LengthMeasurable {
    var asData: Data { get }
    var bytes: [Byte] { get }
    func toData(minByteCount: Int?, concatMode: ConcatMode) -> Data
    func toHexString(case: String.Case?, mode: StringConversionMode?) -> HexString
    func toBase64String(minLength: Int?) -> Base64String
    func toBase58String(minLength: Int?) -> Base58String
}

// MARK: - Default Implementation
public extension DataConvertible {
    func toData(minByteCount expectedLength: Int? = nil, concatMode: ConcatMode = .prepend) -> Data {
      
        guard let expectedLength = expectedLength else {
            return self.asData
        }
        var modified: Data = self.asData
        let new = Byte(0x0)
        while modified.length < expectedLength {
            switch concatMode {
            case .prepend: modified = new + modified
            case .append: modified = modified + new
            }
        }
        return modified
        
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

// MARK: - Conformance
extension Array: DataConvertible where Element == Byte {
    public var asData: Data {
        return Data(self)
    }
}
