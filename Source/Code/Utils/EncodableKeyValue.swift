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
    public let dsonEncodedValue: DSON
    public let output: DSONOutput
    init(key unencodedKey: String, encoded dsonEncodedValue: DSON, output: DSONOutput) {
        self.key = unencodedKey
        self.dsonEncodedValue = dsonEncodedValue
        self.output = output
    }
    
    init<Value>(key: String, encodable: Value, output: DSONOutput = .all) throws where Value: DSONEncodable {
        self.init(key: key, encoded: try encodable.toDSON(output: output), output: output)
    }
    
    public func cborEncodedKey() -> [UInt8] {
        return CBOR.utf8String(key).encode()
    }
}

public struct EncodableKeyValue<Key: CodingKey> {
    public typealias Container = KeyedEncodingContainer<Key>
    public typealias JSONEncoding<Value: Encodable> = (inout Container, Value, Key) throws -> Void
    
    private let _jsonEncode: (inout Container) throws -> Void
    private let _dsonEncode: () throws -> DSON
    private let key: String
    public let output: DSONOutput
    init<Value>(
        key: Key,
        value: Value,
        output: DSONOutput = .all,
        jsonEncoding: @escaping JSONEncoding<Value> = { try $0.encode($1, forKey: $2) }
    ) where Value: Encodable & DSONEncodable {
        self.key = key.stringValue
        self.output = output
        _jsonEncode = { container in
            try jsonEncoding(&container, value, key)
        }
        _dsonEncode = {
            try value.toDSON(output: output)
        }
    }
    
    public func dsonEncodedValue() throws -> DSON {
        return try _dsonEncode()
    }
    
    public func jsonEncoded(by container: inout KeyedEncodingContainer<Key>) throws {
        try _jsonEncode(&container)
    }
}

public extension EncodableKeyValue {
    init?<ConditionalValue, Value>(
        key: Key,
        nonEmpty lengthMeasurable: ConditionalValue,
        value: (ConditionalValue) -> Value,
        output: DSONOutput = .all,
        jsonEncoding: @escaping JSONEncoding<Value> = { try $0.encode($1, forKey: $2) }
        ) where ConditionalValue: LengthMeasurable, Value: Encodable & DSONEncodable {
        guard lengthMeasurable.length > 0 else {
            return nil
        }
        self.init(key: key, value: value(lengthMeasurable), output: output, jsonEncoding: jsonEncoding)
    }
    
    init?<Value>(
        key: Key,
        nonEmpty lengthMeasurable: Value,
        output: DSONOutput = .all,
        jsonEncoding: @escaping JSONEncoding<Value> = { try $0.encode($1, forKey: $2) }
        ) where Value: Encodable & DSONEncodable & LengthMeasurable {
        guard lengthMeasurable.length > 0 else {
            return nil
        }
        self.init(key: key, value: lengthMeasurable, output: output, jsonEncoding: jsonEncoding)
    }
    
    func toCBOREncodableProperty() throws -> CBOREncodableProperty {
        return CBOREncodableProperty(key: key, encoded: try _dsonEncode(), output: output)
    }
}
