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
        let prefixedString = try decode(PrefixedStringWithValue.self, forKey: key)
        return try D(prefixedString: prefixedString)
    }
    
    func decodeIfPresent<D>(_ type: D.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> D? where D: Decodable & PrefixedJsonDecodable {
        guard let prefixedString = try decodeIfPresent(PrefixedStringWithValue.self, forKey: key) else {
            return nil
        }
        return try D(prefixedString: prefixedString)
    }
}

public extension SingleValueDecodingContainer {
    func decode<D>(_ type: D.Type) throws -> D where D: Decodable & PrefixedJsonDecodable {
        let prefixedString = try decode(PrefixedStringWithValue.self)
        return try D(prefixedString: prefixedString)
    }
}
