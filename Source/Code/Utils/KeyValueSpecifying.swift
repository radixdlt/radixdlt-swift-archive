//
//  KeyValueSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol KeyValueSpecifying: CBORPropertyListConvertible {
    associatedtype CodingKeys: CodingKey
    var keyValues: [EncodableKeyValue<CodingKeys>] { get }
}

// MARK: - CBORPropertyListConvertible
public extension KeyValueSpecifying {
    var propertyList: [CBOREncodableProperty] {
        return keyValues.map { $0.toCBOREncodableProperty() }
    }
}

// MARK: Encodable
public extension Encodable where Self: KeyValueSpecifying {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let modelTypeSpecyfing = self as? RadixModelTypeSpecifying {
            let typeKey = CodingKeys(stringValue: RadixModelType.jsonKey)!
            try container.encode(modelTypeSpecyfing.type, forKey: typeKey)
        }
        try keyValues.forEach {
            try $0.jsonEncoded(by: &container)
        }
    }
}
