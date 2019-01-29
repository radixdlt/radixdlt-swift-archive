//
//  TokenAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct StringDson<Value: StringInitializable>: DsonConvertible {
    public let value: Value
}

// MARK: DsonConvertible
public extension DsonConvertible where Self: StringInitializable, Self.From == String {
    init(from string: String) throws {
        try self.init(string: string)
    }
}

// MARK: DsonConvertible
public extension StringDson {
    static var tag: DsonTag {
        return .string
    }
    init(from string: String) throws {
        value = try Value(string: string)
    }
    
    var description: String {
        return String(describing: value)
    }
}

/// Verb version of `FungibleType`
public enum TokenAction: String, StringInitializable, Hashable {
    case mint
    case transfer
    case burn
}

// MARK: - StringInitializable
public extension TokenAction {
    init(string: String) throws {
        guard let type = TokenAction(rawValue: string) else {
            throw Error.unsupportedTokenAction(string)
        }
        self = type
    }
}

// MARK: DsonConvertible
public extension TokenAction {
    static let tag: DsonTag = .string
    init(from string: String) throws {
        try self.init(string: string)
    }
}

// MARK: CustomStringConvertible
public extension TokenAction {
    var description: String {
        return rawValue
    }
}

// MARK: - Error
public extension TokenAction {
    public enum Error: Swift.Error {
        case unsupportedTokenAction(String)
    }
}
