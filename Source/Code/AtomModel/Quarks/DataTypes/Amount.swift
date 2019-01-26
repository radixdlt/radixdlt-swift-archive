//
//  Amount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Amount: DsonConvertible, StringInitializable, Equatable, Codable, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral {
    public typealias Value = BigUnsignedInt
    
    public let value: Value
    
    public init(value: Value) {
        self.value = value
    }
}

// MARK: - StringInitializable
public extension Amount {
    init(string: String) throws {
        guard let value = Value(string, radix: 10) else {
            throw Error.failedToCreateBigInt(fromString: string)
        }
        self.init(value: value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension Amount {
    init(integerLiteral int: Int) {
        self.init(value: Value(int))
    }
}

// MARK: - ExpressibleByStringLiteral
public extension Amount {
    init(stringLiteral value: String) {
        do {
            try self.init(string: value)
        } catch {
            fatalError("Passed decimal string passed: `\(value)`, error: \(error)")
        }
    }
}

// MARK: - DsonConvertible
public extension Amount {
    init(from string: String) throws {
        try self.init(string: string)
    }
}

// MARK: - CustomStringConvertible
public extension Amount {
    var description: String {
        return value.description
    }
}

// MARK: - Error
public extension Amount {
    public enum Error: Swift.Error {
        case failedToCreateBigInt(fromString: String)
    }
}
