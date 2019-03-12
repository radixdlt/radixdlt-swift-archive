//
//  EncodableKeyValue.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

public struct EncodableKeyValue<Key: CodingKey>: CBOREncodable {
    public typealias Container = KeyedEncodingContainer<Key>
    public typealias JSONEncoding<Value: Encodable> = (inout Container, Value, Key) throws -> Void
    
    private let _jsonEncode: (inout Container) throws -> Void
    private let _cborEncodedValue: [Byte]
    public let key: String
    init<Value>(
        key: Key,
        value: Value,
        jsonEncoding: @escaping JSONEncoding<Value> = { try $0.encode($1, forKey: $2) }
    ) where Value: Encodable & CBOREncodable {
        self.key = key.stringValue
        _jsonEncode = { container in
            try jsonEncoding(&container, value, key)
        }
        _cborEncodedValue = value.encode()
    }
    
    public func jsonEncoded(by container: inout KeyedEncodingContainer<Key>) throws {
        try _jsonEncode(&container)
    }
    
    public func encode() -> [UInt8] {
        return _cborEncodedValue
    }
    
    public func cborEncodedKey() -> [UInt8] {
        return CBOR.utf8String(key).encode()
    }
}
