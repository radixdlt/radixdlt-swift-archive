//
//  PrefixedJsonDecodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol PrefixedJsonDecodable: Decodable, StringInitializable {
    static var jsonPrefix: JSONPrefix { get }
    init(prefixedString: PrefixedStringWithValue) throws
}

public extension PrefixedJsonDecodable where Self: StringRepresentable {
    static var jsonPrefix: JSONPrefix {
        return .string
    }
}

public extension PrefixedJsonDecodable {
    init(prefixedString: PrefixedStringWithValue) throws {
        guard prefixedString.jsonPrefix == Self.jsonPrefix else {
            throw PrefixedStringWithValue.Error.prefixMismatch(expected: Self.jsonPrefix, butGot: prefixedString.jsonPrefix)
        }
        try self.init(string: prefixedString.stringValue)
    }
}

public protocol PrefixedJsonEncodable: Encodable {
    var prefixedString: PrefixedStringWithValue { get }
}

public extension PrefixedJsonEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(prefixedString.identifer)
    }
}

/// Ugly hack to resolve "candidate exactly matches" error since RawRepresentable have a default `encode` function, and the compiler is unable to distinguish between the RawRepresentable `encode` and the PrefixedJsonCodable `encode` function.
extension RawRepresentable where Self: PrefixedJsonCodable, Self.RawValue == String {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(prefixedString.identifer)
    }
}

public extension PrefixedJsonEncodable where Self: StringRepresentable, Self: PrefixedJsonDecodable {
    var prefixedString: PrefixedStringWithValue {
        return PrefixedStringWithValue(value: stringValue, prefix: Self.jsonPrefix)
    }
}

public typealias PrefixedJsonCodable = PrefixedJsonDecodable & PrefixedJsonEncodable
