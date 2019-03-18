//
//  AnyEncodableKeyValueListConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AnyEncodableKeyValueListConvertible: DSONEncodable {
    func anyEncodableKeyValues(output: DSONOutput) throws -> [AnyEncodableKeyValue]
}

// MARK: - DSONEncodable
public extension AnyEncodableKeyValueListConvertible {
    
    /// Radix type "map", according to this: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
    /// Format is this:
    /// 0xbf (encodeMapStreamStart)
    /// [propertyName (CBOREncoded) + propertyValue (CBOREncoded)] for each property
    /// 0xff (encodeStreamEnd)
    func toDSON(output: DSONOutput = .all) throws -> DSON {
        var properties = try anyEncodableKeyValues(output: output)
        properties = properties.filter { $0.output >= output }
        if let processor = self as? AnyEncodableKeyValuesProcessing {
            properties = try processor.processProperties(properties)
        }
        
        return [
            CBOR.encodeMapStreamStart(),
            properties.flatMap { $0.cborEncodedKey() + $0.dsonEncodedValue },
            CBOR.encodeStreamEnd()
        ].flatMap { $0 }.asData
    }
}
