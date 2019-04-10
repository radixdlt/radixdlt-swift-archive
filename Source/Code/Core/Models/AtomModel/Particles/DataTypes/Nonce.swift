//
//  Nonce.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// A random value between [Int.min...Int.max]
public struct Nonce:
    CBORConvertible,
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

public extension Nonce {
    static func += (nonce: inout Nonce, increment: Value) {
        nonce.value += increment
    }
}

// MARK: - CustomStringConvertible
public extension Nonce {
    var description: String {
        return value.description
    }
}

// MARK: - CBORConvertible
public extension Nonce {
    func toCBOR() -> CBOR {
        return CBOR.int64(value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Nonce {
    init(integerLiteral value: Value) {
        self.value = value
    }
}

// MARK: - Decodable
public extension Nonce {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(Value.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
