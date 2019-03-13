//
//  CBORStreamable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

public protocol CBORPropertyListConvertible: CBOREncodable {
    var propertyList: [CBOREncodableProperty] { get }
}

public protocol CBORPropertyListProcessing {
    typealias Processor = ([CBOREncodableProperty]) -> [CBOREncodableProperty]
    var processProperties: Processor { get }
}

// MARK: - CBOREncodable
public extension CBORPropertyListConvertible {
    
    /// Radix type "map", according to this: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
    /// Format is this:
    /// 0xbf (encodeMapStreamStart)
    /// [propertyName (CBOREncoded) + propertyValue (CBOREncoded)] for each property
    /// 0xff (encodeStreamEnd)
    func encode() -> [UInt8] {
        var properties = self.propertyList
        if let processor = self as? CBORPropertyListProcessing {
            properties = processor.processProperties(properties)
        }
        
        return [
            CBOR.encodeMapStreamStart(),
            properties.flatMap { $0.cborEncodedKey() + $0.cborEncodedValue },
            CBOR.encodeStreamEnd()
            ].flatMap { $0 }
    }
}

public protocol CBORStreamable: KeyValueSpecifying, CBORPropertyListProcessing {}

public extension CBORStreamable {
    
    var processProperties: Processor {
        return {
            var properties = $0
            properties.append(CBOREncodableProperty(key: "version", encodable: 100))
            if let modelTypeSpecyfing = self as? RadixModelTypeSpecifying {
                properties.append(CBOREncodableProperty(key: RadixModelType.jsonKey, encodable: modelTypeSpecyfing.type.serializerId))
            }
            return properties.sorted(by: \.key)
        }
    }
}
