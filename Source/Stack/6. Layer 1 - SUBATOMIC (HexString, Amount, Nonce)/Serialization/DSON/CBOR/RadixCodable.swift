//
//  RadixCodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

let jsonKeyVersion = "version"
let serializerVersion = 100

public protocol RadixCodable: EncodableKeyValueListConvertible, AnyEncodableKeyValueListConvertible, AnyEncodableKeyValuesProcessing {}

public extension RadixCodable {
    
    var preProcess: Process {
        return { keyValues, output in
            var keyValues = keyValues
            keyValues.append(try AnyEncodableKeyValue(key: jsonKeyVersion, encodable: serializerVersion, output: .all))
            
            if let modelTypeSpecyfing = self as? RadixModelTypeStaticSpecifying {
                keyValues.append(try AnyEncodableKeyValue(key: RadixModelType.jsonKey, encodable: modelTypeSpecyfing.serializer.serializerId, output: .all))
            }
            
            return keyValues
        }
    }
}
