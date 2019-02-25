//
//  StringConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum InvalidStringError: Swift.Error {
    case invalidCharacters(expectedCharacters: CharacterSet, butGot: String)
    case tooManyCharacters(expectedAtMost: Int, butGot: Int)
    case tooFewCharacters(expectedAtLeast: Int, butGot: Int)
    
}

public protocol UpperBound {
    static var maxValue: Int { get }
}

public protocol MaxLengthSpecifying: UpperBound {
    static var maxLength: Int { get }
}

public extension MaxLengthSpecifying {
    static var maxValue: Int {
        return maxLength
    }
}

public extension UpperBound {
    var maxValue: Int {
        return Self.maxValue
    }
    
    static func validateLength(of string: String) throws {
        if string.count > maxValue {
            throw InvalidStringError.tooManyCharacters(expectedAtMost: maxValue, butGot: string.count)
        }
    }
}

public protocol LowerBound {
    static var minValue: Int { get }
}

public protocol MinLengthSpecifying: LowerBound {
    static var minLength: Int { get }
}

public extension MinLengthSpecifying {
    static var minValue: Int {
        return minLength
    }
}

public extension LowerBound {
    var minValue: Int {
        return Self.minValue
    }
    
    static func validateLength(of string: String) throws {
        if string.count < minValue {
            throw InvalidStringError.tooFewCharacters(expectedAtLeast: minValue, butGot: string.count)
        }
    }
}

public protocol StringConvertible: StringInitializable, Hashable, ExpressibleByStringLiteral {
    var value: String { get }
    
    /// Calling this with an invalid String will result in runtime crash.
    init(validated: String)
    static func validate(_ string: String) throws -> String
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
    init(stringLiteral value: String) {
        do {
            self = try Self.init(string: value)
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
    init(string: String) throws {
        self.init(validated: try Self.validate(string))
    }
}

extension StringConvertible {
    public static func validate(_ string: String) throws -> String {
        if let characterSetSpecifying = self as? CharacterSetSpecifying.Type {
            try characterSetSpecifying.validate(string)
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
