//
//  Nonce.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Nonce: Codable, Equatable, ExpressibleByIntegerLiteral {
    public typealias Value = Int64
    public let value: Value
    
    public init() {
        value = Int64.random(in: Value.min...Value.max)
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
}
