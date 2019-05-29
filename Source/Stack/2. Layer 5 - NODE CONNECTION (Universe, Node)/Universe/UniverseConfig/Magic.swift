//
//  Magic.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// An 64-bit signed integer involved in formatting of addresses from Public Keys
/// that are unique per Radix Universe ("network"/"chain id", as in Radix Alphanet, Betanet etc.)
public struct Magic:
    CBORConvertible,
    DataConvertible,
    CustomStringConvertible,
    Codable,
    Equatable,
    ExpressibleByIntegerLiteral {
    // swiftlint:enable colon
    
    public typealias Value = Int64
    public private(set) var value: Value
    
    public init() {
        value = Int64.random(in: Value.min...Value.max)
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
        return value.asData
    }
}

// MARK: - CBORConvertible
public extension Magic {
    func toCBOR() -> CBOR {
        return CBOR.int64(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Magic {
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
