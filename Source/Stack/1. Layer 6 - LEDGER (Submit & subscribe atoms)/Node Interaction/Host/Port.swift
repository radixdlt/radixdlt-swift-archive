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
    
    public init(unvalidated: Int) throws {
        guard let port = Value(exactly: unvalidated) else {
            throw Error.invalidExpectedUInt16(butGot: unvalidated)
        }
        self.init(port)
    }
    
    enum Error: Swift.Error {
        case invalidExpectedUInt16(butGot: Int)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(unvalidated: container.decode(Int.self))
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
