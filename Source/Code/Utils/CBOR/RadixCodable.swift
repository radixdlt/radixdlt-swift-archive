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
    
    func processProperties(_ properties: [AnyEncodableKeyValue]) throws -> [AnyEncodableKeyValue] {
        var properties = properties
        properties.append(try AnyEncodableKeyValue(key: jsonKeyVersion, encodable: 100))
        if let modelTypeSpecyfing = self as? RadixModelTypeSpecifying {
            properties.append(try AnyEncodableKeyValue(key: RadixModelType.jsonKey, encodable: modelTypeSpecyfing.type.serializerId))
        }
        
        return properties.sorted(by: \.key)
    }
}
