//
//  PrefixedJsonEncodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-08.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol PrefixedJsonEncodable: JSONPrefixSpecifying, Encodable {
    var prefixedString: PrefixedStringWithValue { get }
}

public extension PrefixedJsonEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(prefixedString.identifer)
    }
}

/// Ugly hack to resolve "candidate exactly matches" error since RawRepresentable have a default `encode` function, and the compiler is unable to distinguish between the RawRepresentable `encode` and the PrefixedJsonCodable `encode` function.
extension RawRepresentable where Self: PrefixedJsonEncodable, Self.RawValue == String {
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
