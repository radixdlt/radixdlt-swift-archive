//
//  Port.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// Network Port represented as UInt16
public struct Port:
    CBORConvertible,
    Throwing,
    CustomStringConvertible,
    Codable,
    Hashable,
    ExpressibleByIntegerLiteral
{
    // swiftlint:enable colon opening_brace
    
    public typealias Value = UInt16
    public let port: Value
    
    public init(_ port: Value) {
        self.port = port
    }
}

public extension Port {
    init(unvalidated: Int) throws {
        guard let port = Value(exactly: unvalidated) else {
            throw Error.invalidExpectedUInt16(butGot: unvalidated)
        }
        self.init(port)
    }
}

// MARK: - Decodable
public extension Port {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(unvalidated: container.decode(Int.self))
    }
}

// MARK: - Throwing
public extension Port {
    enum Error: Swift.Error, Equatable {
        case invalidExpectedUInt16(butGot: Int)
    }
}

// MARK: - CustomStringConvertible
public extension Port {
    var description: String {
        return port.description
    }
}

// MARK: - CBORConvertible
public extension Port {
    func toCBOR() -> CBOR {
        return CBOR.int64(Int64(port))
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Port {
    init(integerLiteral value: Value) {
        self.init(value)
    }
}

// MARK: - Presets
public extension Port {
    static let localhost: Port = 8080
    static let nodeFinder: Port = 443
}
