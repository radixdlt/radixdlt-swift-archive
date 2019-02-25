//
//  KeyedDecodingContainer+PrefixedJson+Decode.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension KeyedDecodingContainer {
    func decode<D>(_ type: D.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> D where D: Decodable & PrefixedJsonDecodable {
        return try decode(PrefixedJson<D>.self, forKey: key).value
    }
}

public extension SingleValueDecodingContainer {
    func decodePrefixed<D>(_ type: D.Type) throws -> D where D: Decodable & PrefixedJsonDecodable {
        return try decode(PrefixedJson<D>.self).value
    }
}
