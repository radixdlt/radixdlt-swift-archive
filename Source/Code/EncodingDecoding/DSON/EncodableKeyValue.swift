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
    private let _dsonEncode: (DSONOutput) throws -> DSON
    private let key: String
    private let output: DSONOutput
    
    init<Value>(
        key: Key,
        value: Value,
        output: DSONOutput = .default,
        jsonEncoding: @escaping JSONEncoding<Value> = { try $0.encode($1, forKey: $2) }
    ) where Value: Encodable & DSONEncodable {
        self.key = key.stringValue
        self.output = output
        _jsonEncode = { container in
            try jsonEncoding(&container, value, key)
        }
        _dsonEncode = {
            try value.toDSON(output: $0)
        }
    }
    
    public func jsonEncoded(by container: inout KeyedEncodingContainer<Key>) throws {
        try _jsonEncode(&container)
    }
}

// MARK: - Full Type-Erasure (to AnyEncodableKeyValue)
public extension EncodableKeyValue {
    func toAnyEncodableKeyValue(output overridingOutput: DSONOutput) throws -> AnyEncodableKeyValue {
        // Important that we initialize this `AnyEncodableKeyValue` with the DSONOutput passed when this `EncodableKeyValue` was initialize
        // But that we are using `overridingOutput` in `_dsonEncode` closure.
        return AnyEncodableKeyValue(key: key, encoded: try _dsonEncode(overridingOutput), output: self.output)
    }
}

// MARK: - Convenience Init
public extension EncodableKeyValue {
    
    init?<Value>(
        key: Key,
        ifPresent value: Value?,
        output: DSONOutput = .default,
        jsonEncoding: @escaping JSONEncoding<Value> = { try $0.encode($1, forKey: $2) }
        ) where Value: Encodable & DSONEncodable {
        
        guard let value = value else {
            return nil
        }
        
        self.init(key: key, value: value, output: output, jsonEncoding: jsonEncoding)
    }
    
    init?<ConditionalValue, Value>(
        key: Key,
        nonEmpty lengthMeasurable: ConditionalValue,
        value: (ConditionalValue) -> Value,
        output: DSONOutput = .default,
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
        output: DSONOutput = .default,
        jsonEncoding: @escaping JSONEncoding<Value> = { try $0.encode($1, forKey: $2) }
        ) where Value: Encodable & DSONEncodable & LengthMeasurable {
        guard lengthMeasurable.length > 0 else {
            return nil
        }
        self.init(key: key, value: lengthMeasurable, output: output, jsonEncoding: jsonEncoding)
    }
}
