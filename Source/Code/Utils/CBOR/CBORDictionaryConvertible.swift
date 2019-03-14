//
//  CBORDictionaryConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol CBORDictionaryConvertible: CBORPropertyListConvertible,
    CBORPropertyListProcessing,
    DictionaryConvertible {
    func valueDSONEncode(_ value: Value, output: DSONOutput) throws -> DSON
}

// MARK: - CBORPropertyListConvertible
public extension CBORDictionaryConvertible where Key: StringRepresentable {
    func propertyList(output: DSONOutput) throws -> [CBOREncodableProperty] {
        return try dictionary.map {
            CBOREncodableProperty(key: $0.key.stringValue, encoded: try valueDSONEncode($0.value, output: output))
        }
    }
}

// MARK: - CBORPropertyListProcessing
public extension CBORDictionaryConvertible {
    func processProperties(_ properties: [CBOREncodableProperty]) throws -> [CBOREncodableProperty] {
        return properties.sorted(by: \.key)
    }
}

public extension CBORDictionaryConvertible where Value: StringRepresentable {
    func valueDSONEncode(_ value: Value, output: DSONOutput) throws -> DSON {
        return try CBOR(stringLiteral: value.stringValue).toDSON(output: output)
    }
}

public extension CBORDictionaryConvertible where Value: DSONEncodable {
    func valueDSONEncode(_ value: Value, output: DSONOutput) throws -> DSON {
        return try value.toDSON(output: output)
    }
}

/// Ugly hack to resolve "candidate exactly matches" error since compiler is unable to distinguish between implementation `where Value: StringRepresentable` and `where Value: DSONEncodable`
public extension CBORDictionaryConvertible where Value == String {
    func valueDSONEncode(_ value: Value, output: DSONOutput) throws -> DSON {
        return try CBOR(stringLiteral: value).toDSON(output: output)
    }
}
