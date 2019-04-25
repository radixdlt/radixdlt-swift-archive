//
//  Planck.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// A seemlingly random, strict positive integer, based on current time.
public struct Planck:
    CBORConvertible,
    Codable,
    Equatable,
    ExpressibleByIntegerLiteral {
// swiftlint:enable colon
    
    public typealias Value = UInt64
    let value: Value
    
    public init() {
        let millisecondsSince1970 = Value(TimeConverter.millisecondsFrom(date: Date()))
        let msPerMinute = Value(60000)
        value = millisecondsSince1970/msPerMinute + msPerMinute
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
