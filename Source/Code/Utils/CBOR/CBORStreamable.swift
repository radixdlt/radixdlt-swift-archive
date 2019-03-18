//
//  CBORStreamable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

let jsonKeyVersion = "version"

public protocol CBORStreamable: KeyValueSpecifying, CBORPropertyListProcessing {}

public extension CBORStreamable {
    
    func processProperties(_ properties: [CBOREncodableProperty]) throws -> [CBOREncodableProperty] {
        var properties = properties
        properties.append(try CBOREncodableProperty(key: jsonKeyVersion, encodable: 100))
        if let modelTypeSpecyfing = self as? RadixModelTypeSpecifying {
            properties.append(try CBOREncodableProperty(key: RadixModelType.jsonKey, encodable: modelTypeSpecyfing.type.serializerId))
        }
        
        return properties.sorted(by: \.key)
    }
}
