//
//  StringConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol StringConvertibleError: Swift.Error {
    static var invalidCharactersError: Self { get }
}

public protocol StringConvertibleErrorOwner {
    associatedtype Error: StringConvertibleError
}

public protocol StringConvertible: Hashable, Codable, ExpressibleByStringLiteral, CustomStringConvertible {
    var value: String { get }
    
    /// Calling this with an invalid String will result in runtime crash.
    init(validated: String)
    
    init(string value: String) throws
    
    static func validate(_ string: String) throws -> String
}

public extension StringConvertible {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(validated: try container.decode(String.self))
    }
    
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

// MARK: - Default Implementation
public extension StringConvertible {
    init(string: String) throws {
        self.init(validated: try Self.validate(string))
    }
}

// MARK: - Default Implementation Constrained
extension StringConvertible where Self: CharacterSetSpecifying, Self: StringConvertibleErrorOwner {
    public static func validate(_ string: String) throws -> String {
        guard Self.allowedCharacters.isSuperset(of: CharacterSet(charactersIn: string)) else {
            throw Error.invalidCharactersError
        }
        // Valid
        return string
    }
}
