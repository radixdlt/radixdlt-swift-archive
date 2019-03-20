//
//  EncodableKeyValue.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A partially type-erased container of an encodable Value for a certain CodingKey. The CodingKey is not type-erased, it is held by the generic passed to this struct. The encodable `Value`, however, is type-erased.
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
    
    func toAnyEncodableKeyValue() throws -> AnyEncodableKeyValue {
        return AnyEncodableKeyValue(key: key, encoded: try _dsonEncode(), output: output)
    }
}
