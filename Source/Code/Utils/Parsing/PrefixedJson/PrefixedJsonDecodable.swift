//
//  PrefixedJsonDecodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol PrefixedJsonDecodable: JSONPrefixSpecifying, Decodable, StringInitializable {
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
