//
//  Magic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// An 32-bit signed integer involved in formatting of addresses from Public Keys
/// that are unique per Radix Universe ("network"/"chain id", as in Radix Alphanet, Betanet etc.)
public struct Magic:
    CBORConvertible,
    DataConvertible,
    CustomStringConvertible,
    Codable,
    Equatable,
    ExpressibleByIntegerLiteral {
    // swiftlint:enable colon
    
    public typealias Value = Int32
    private let value: Value
    
    private init() {
        abstract("Never create magic, just fetch from API")
    }
}

private extension Magic {
    var valueForEncodingAndDecoding: Int64 {
        return Int64(value)
    }
}

internal extension Magic {
    // MARK: - Endianess (Matching Java library ByteStream `putInt`)
    func toFourBigEndianBytes() -> [Byte] {
        let uint32 = UInt32(truncatingIfNeeded: value)
        let endianessSwapped = CFSwapInt32HostToBig(uint32)
        
        let magic4Bytes = endianessSwapped.bytes
        assert(magic4Bytes.count == 4)
        return magic4Bytes
    }
}

// MARK: - CustomStringConvertible
public extension Magic {
    var description: String {
        return value.description
    }
}

// MARK: - DataConvertible
public extension Magic {
    var asData: Data {
        return valueForEncodingAndDecoding.asData
    }
}

// MARK: - CBORConvertible
public extension Magic {
    func toCBOR() -> CBOR {
        return CBOR.int64(valueForEncodingAndDecoding)
    }
}

// MARK: - ExpressibleByIntegerLiteral - For Testing purposes
public extension Magic {
    /// For testing purposes
    init(integerLiteral value: Value) {
        self.value = value
    }
}

// MARK: - Decodable
public extension Magic {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Value.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - Public
public extension Magic {
    var byte: Byte {
        return asData[0]
    }
}
