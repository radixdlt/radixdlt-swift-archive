//
//  StringConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol StringConvertible: StringInitializable, StringRepresentable, ValueValidating, Hashable, CustomStringConvertible {
    var value: String { get }
    
    /// Calling this with an invalid String will result in runtime crash.
    init(validated: String)
}

// MARK: - StringRepresentable
public extension StringConvertible {
    var stringValue: String {
        return value
    }
}

public extension PrefixedJsonDecodable where Self: StringConvertible {
    static var jsonPrefix: JSONPrefix {
        return .string
    }
}

// MARK: - ExpressibleByStringLiteral
public extension StringConvertible {
    init(stringLiteral string: String) {
        do {
            self = try Self.init(string: string)
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
