//
//  StringDson.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
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
