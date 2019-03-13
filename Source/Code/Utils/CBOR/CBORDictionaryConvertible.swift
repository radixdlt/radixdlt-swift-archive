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
    var valueCBOREncoder: (Value) -> [Byte] { get }
}

// MARK: - CBORPropertyListConvertible
public extension CBORDictionaryConvertible where Key: StringRepresentable {
    var propertyList: [CBOREncodableProperty] {
        return self.dictionary.map {
            CBOREncodableProperty(key: $0.key.stringValue, encoded: valueCBOREncoder($0.value))
        }
    }
}

// MARK: - CBORPropertyListProcessing
public extension CBORDictionaryConvertible {
    var processProperties: Processor {
        return { $0.sorted(by: \.key) }
    }
}

public extension CBORDictionaryConvertible where Value: StringRepresentable {
    var valueCBOREncoder: (Value) -> [Byte] {
        return {
            CBOR(stringLiteral: $0.stringValue).encode()
        }
    }
}

public extension CBORDictionaryConvertible where Value: DSONEncodable {
    var valueCBOREncoder: (Value) -> [Byte] {
        return { $0.encode() }
    }
}

/// Ugly hack to resolve "candidate exactly matches" error since compiler is unable to distinguish between implementation `where Value: StringRepresentable` and `where Value: DSONEncodable`
public extension CBORDictionaryConvertible where Value == String {
    var valueCBOREncoder: (Value) -> [Byte] {
        return {
            CBOR(stringLiteral: $0.stringValue).encode()
        }
    }
}
