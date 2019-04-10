//
//  AnyEncodableKeyValueList.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// A fully type-erased container of AnyEncodableKeyValue
public struct AnyEncodableKeyValueList: AnyEncodableKeyValueListConvertible {
    
    private let _keyValues: (DSONOutput) throws -> [AnyEncodableKeyValue]
    
    init<K>(keyValues: [EncodableKeyValue<K>]) throws where K: CodingKey {
        _keyValues = { overridingDsonOutput in
            return try keyValues.map { try $0.toAnyEncodableKeyValue(output: overridingDsonOutput) }
        }
    }
}

// MARK: - AnyEncodableKeyValueListConvertible
public extension AnyEncodableKeyValueList {
    func anyEncodableKeyValues(output: DSONOutput) throws -> [AnyEncodableKeyValue] {
        return try _keyValues(output)
    }
}
