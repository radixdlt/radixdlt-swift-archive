//
//  StringConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol StringConvertible: StringInitializable, ValueValidating, Hashable, ExpressibleByStringLiteral {
    var value: ValidationValue { get }
    
    /// Calling this with an invalid String will result in runtime crash.
    init(validated: ValidationValue)
}

public extension PrefixedJsonDecodable where Self: StringConvertible {
    public static var tag: JSONPrefix {
        return .string
    }
}

// MARK: - Decodable
public extension StringConvertible {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(validated: try container.decode(String.self))
    }
}

// MARK: - Encodable
public extension StringConvertible {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - ExpressibleByStringLiteral
public extension StringConvertible {
    init(stringLiteral string: String) {
        do {
            self = try Self.init(value: string)
        } catch {
            fatalError("Bad string, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension StringConvertible {
    var description: String {
        return value
    }
}

// MARK: - Public Convenience
public extension StringConvertible {
    var length: Int {
        return value.count
    }
    
    var isEmpty: Bool {
        return length == 0
    }
}

// MARK: - StringInitializable
public extension StringConvertible {
    init(value string: String) throws {
        self.init(validated: try Self.validate(value: string))
    }
}

extension StringConvertible {
    public static func validate(value string: Value) throws -> Value {
        if let characterSetSpecifying = self as? CharacterSetSpecifying.Type {
            try characterSetSpecifying.validate(value: string)
        }
        
        if let lowerBound = self as? LowerBound.Type {
            try lowerBound.validateLength(of: string)
        }
    
        if let upperBound = self as? UpperBound.Type {
            try upperBound.validateLength(of: string)
        }
        
        return string
    }
}
