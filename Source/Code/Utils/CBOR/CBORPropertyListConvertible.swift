//
//  CBORPropertyListConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol CBORPropertyListConvertible: DSONEncodable {
    func propertyList(output: DSONOutput) throws -> [CBOREncodableProperty]
}

public protocol CBORPropertyListProcessing {
    func processProperties(_ properties: [CBOREncodableProperty]) throws -> [CBOREncodableProperty]
}

public struct AnyCBORPropertyListConvertible: CBORPropertyListConvertible {

    private let _propertyList: (DSONOutput) throws -> [CBOREncodableProperty]
    
    init<K>(keyValues: [EncodableKeyValue<K>]) throws where K: CodingKey {
        _propertyList = { _ in
            return try keyValues.map { try $0.toCBOREncodableProperty() }
        }
    }
    
    public func propertyList(output: DSONOutput) throws -> [CBOREncodableProperty] {
        return try _propertyList(output)
    }
}

// MARK: - DSONEncodable
public extension CBORPropertyListConvertible {
    
    /// Radix type "map", according to this: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
    /// Format is this:
    /// 0xbf (encodeMapStreamStart)
    /// [propertyName (CBOREncoded) + propertyValue (CBOREncoded)] for each property
    /// 0xff (encodeStreamEnd)
    func toDSON(output: DSONOutput = .all) throws -> DSON {
        var properties = try propertyList(output: output)
        
        if let processor = self as? CBORPropertyListProcessing {
            properties = try processor.processProperties(properties)
        }
        
        return [
            CBOR.encodeMapStreamStart(),
            properties.flatMap { $0.cborEncodedKey() + $0.dsonEncodedValue },
            CBOR.encodeStreamEnd()
        ].flatMap { $0 }.asData
    }
}
