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

let jsonKeyDestinations = "destinations"

public protocol RadixCodable: EncodableKeyValueListConvertible, AnyEncodableKeyValueListConvertible, AnyEncodableKeyValuesProcessing {}

public extension RadixCodable {
    
    var preProcess: Process {
        return { keyValues, output in
            var keyValues = keyValues
            keyValues.append(try AnyEncodableKeyValue(key: jsonKeyVersion, encodable: serializerVersion, output: .all))
            
            if let modelTypeSpecyfing = self as? RadixModelTypeStaticSpecifying {
                keyValues.append(try AnyEncodableKeyValue(key: RadixModelType.jsonKey, encodable: modelTypeSpecyfing.serializer.serializerId, output: .all))
            }
            
            // this is the first "common" JSON property, "common" as in property shared by all Particle types. Move this to some place where we can nicely
            // handle future propertys.
            if let destinationsOwner = self as? DestinationsOwner {
                // For now we only need to encode (and not also decode) "destination", no need to decode it, since it is a computed property.
                keyValues.append(try AnyEncodableKeyValue(key: jsonKeyDestinations, encodable: destinationsOwner.destinations(), output: .all))
            }
            
            return keyValues
        }
    }
}

