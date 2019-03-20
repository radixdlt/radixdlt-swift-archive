//
//  Spin.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum Spin: Int, Equatable, Codable, CustomStringConvertible {
    case neutral = 0
    // swiftlint:disable:next identifier_name
    case up = 1
    case down = -1
}

public extension Spin {
    public var description: String {
        switch self {
        case .neutral: return "neutral"
        case .up: return "up"
        case .down: return "down"
        }
    }
}

extension Spin: DSONEncodable {
    public func toDSON(output: DSONOutput = .default) throws -> DSON {
        return try CBOR(integerLiteral: rawValue).toDSON()
    }
}
