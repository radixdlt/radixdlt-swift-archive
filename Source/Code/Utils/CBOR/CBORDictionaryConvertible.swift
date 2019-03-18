//
//  CBORDictionaryConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// /// A KeyValue-d Collection that can be represented as an array of `AnyEncodableKeyValue`.
public protocol CBORDictionaryConvertible:
    DictionaryConvertible,
    AnyEncodableKeyValueListConvertible,
    AnyEncodableKeyValuesProcessing {
// swiftlint:enable colon
    func valueDSONEncode(_ value: Value, output: DSONOutput) throws -> DSON
}

// MARK: - AnyEncodableKeyValueListConvertible
public extension CBORDictionaryConvertible where Key: StringRepresentable {
    func anyEncodableKeyValues(output: DSONOutput = .default) throws -> [AnyEncodableKeyValue] {
        return try dictionary.map {
            AnyEncodableKeyValue(
                key: $0.key.stringValue,
                encoded: try valueDSONEncode($0.value, output: output),
                output: output
            )
        }.filter { $0.output >= output }
    }
}

// MARK: - AnyEncodableKeyValuesProcessing
public extension CBORDictionaryConvertible {
    func process(keyValues: [AnyEncodableKeyValue]) throws -> [AnyEncodableKeyValue] {
        return keyValues.sorted(by: \.key)
    }
}

public extension CBORDictionaryConvertible where Value: StringRepresentable {
    func valueDSONEncode(_ value: Value, output: DSONOutput = .default) throws -> DSON {
        return try CBOR(stringLiteral: value.stringValue).toDSON(output: output)
    }
}

public extension CBORDictionaryConvertible where Value: DSONEncodable {
    func valueDSONEncode(_ value: Value, output: DSONOutput = .default) throws -> DSON {
        return try value.toDSON(output: output)
    }
}

/// Ugly hack to resolve "candidate exactly matches" error since compiler is unable to distinguish between implementation `where Value: StringRepresentable` and `where Value: DSONEncodable`
public extension CBORDictionaryConvertible where Value == String {
    func valueDSONEncode(_ value: Value, output: DSONOutput) throws -> DSON {
        return try CBOR(stringLiteral: value).toDSON(output: output)
    }
}
