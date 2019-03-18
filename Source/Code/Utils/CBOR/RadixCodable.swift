//
//  RadixCodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

let jsonKeyVersion = "version"

public protocol RadixCodable: EncodableKeyValueListConvertible, AnyEncodableKeyValuesProcessing {}

public extension RadixCodable {
    
    func process(keyValues: [AnyEncodableKeyValue]) throws -> [AnyEncodableKeyValue] {
        var keyValues = keyValues
        keyValues.append(try AnyEncodableKeyValue(key: jsonKeyVersion, encodable: 100))
        if let modelTypeSpecyfing = self as? RadixModelTypeSpecifying {
            keyValues.append(try AnyEncodableKeyValue(key: RadixModelType.jsonKey, encodable: modelTypeSpecyfing.type.serializerId))
        }
        
        return keyValues.sorted(by: \.key)
    }
}
