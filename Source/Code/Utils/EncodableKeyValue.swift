//
//  EncodableKeyValue.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct CBOREncodableProperty {
    public let key: String
    public let cborEncodedValue: [Byte]
    
    init(key unencodedKey: String, encoded cborEncodedValue: [Byte]) {
        self.key = unencodedKey
        self.cborEncodedValue = cborEncodedValue
    }
    
    init<Value>(key: String, encodable: Value) where Value: DSONEncodable {
        self.init(key: key, encoded: encodable.encode())
    }
    
    public func cborEncodedKey() -> [UInt8] {
        return CBOR.utf8String(key).encode()
    }
}

public struct EncodableKeyValue<Key: CodingKey> {
    public typealias Container = KeyedEncodingContainer<Key>
    public typealias JSONEncoding<Value: Encodable> = (inout Container, Value, Key) throws -> Void
    
    private let _jsonEncode: (inout Container) throws -> Void
    private let cborEncodedValue: [Byte]
    private let key: String
    init<Value>(
        key: Key,
        value: Value,
        jsonEncoding: @escaping JSONEncoding<Value> = { try $0.encode($1, forKey: $2) }
    ) where Value: Encodable & DSONEncodable {
        self.key = key.stringValue
        _jsonEncode = { container in
            try jsonEncoding(&container, value, key)
        }
        self.cborEncodedValue = value.encode()
    }
    
    public func jsonEncoded(by container: inout KeyedEncodingContainer<Key>) throws {
        try _jsonEncode(&container)
    }
}

public extension EncodableKeyValue {
    func toCBOREncodableProperty() -> CBOREncodableProperty {
        return CBOREncodableProperty(key: key, encoded: cborEncodedValue)
    }
}
