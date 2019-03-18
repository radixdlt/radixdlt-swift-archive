//
//  Planck.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//swiftlint:disable:next colon
public struct Planck:
    CBORConvertible,
    Codable,
    Equatable,
    ExpressibleByIntegerLiteral {
    
    public typealias Value = UInt64
    let value: Value
    
    public init() {
        let secondsSince1970 = Value(Date().timeIntervalSince1970)
        value = secondsSince1970/60 + 60
    }
}

// MARK: - CBORConvertible
public extension Planck {
    func toCBOR() -> CBOR {
        return CBOR.unsignedInt(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Planck {
    init(integerLiteral value: Value) {
        self.value = value
    }
}

// MARK: - Decodable
public extension Planck {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Value.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
