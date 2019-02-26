//
//  PrefixedJSONDecoder.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol PrefixedJsonDecodable: StringInitializable {
    static var jsonPrefix: JSONPrefix { get }
    init(prefixedString: PrefixedStringWithValue) throws
}

public extension PrefixedJsonDecodable {
    init(prefixedString: PrefixedStringWithValue) throws {
        guard prefixedString.jsonPrefix == Self.jsonPrefix else {
            throw PrefixedStringWithValue.Error.prefixMismatch(expected: Self.jsonPrefix, butGot: prefixedString.jsonPrefix)
        }
        try self.init(string: prefixedString.stringValue)
    }
}

public protocol PrefixedJsonDecodableByProxy: PrefixedJsonDecodable {
    associatedtype Proxy: PrefixedJsonDecodable
    init(proxy: Proxy) throws
}

public extension PrefixedJsonDecodableByProxy {
    static var jsonPrefix: JSONPrefix {
        return Proxy.jsonPrefix
    }
    init(prefixedString: PrefixedStringWithValue) throws {
        let proxy = try Proxy(prefixedString: prefixedString)
        try self.init(proxy: proxy)
    }
}
