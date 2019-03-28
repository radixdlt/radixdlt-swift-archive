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

public protocol RadixCodable: EncodableKeyValueListConvertible, AnyEncodableKeyValuesProcessing {}

public extension RadixCodable {
    
    func process(keyValues: [AnyEncodableKeyValue], output: DSONOutput) throws -> [AnyEncodableKeyValue] {
        var keyValues = keyValues
        keyValues.append(try AnyEncodableKeyValue(key: jsonKeyVersion, encodable: serializerVersion))
        if let modelTypeSpecyfing = self as? RadixModelTypeStaticSpecifying {
            keyValues.append(try AnyEncodableKeyValue(key: RadixModelType.jsonKey, encodable: modelTypeSpecyfing.serializer.serializerId))
        }
        
        return keyValues.sorted(by: \.key).filter { $0.allowsOutput(of: output) }
    }
}
