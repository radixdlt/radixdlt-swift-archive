//
//  MetaDataOwner.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol MetaDataOwner {
    var metaData: MetaData { get }
}

public extension MetaDataOwner {
    func valueFor(key: MetaDataKey, equals expectedValue: MetaDataCommonValue) -> Bool {
        return metaData.valueFor(key: key) == expectedValue.rawValue
    }
}

extension MessageParticle: MetaDataOwner {}
extension ParticleGroup: MetaDataOwner {}

public extension Array where Element: MetaDataOwner {
    
    func firstWhere(metaDatavalue value: MetaData.Value, forKey key: MetaDataKey, condition equality: (MetaData.Value?, MetaData.Value) -> Bool) -> Element? {
        return first(where: { equality($0.metaData.valueFor(key: key), value) })
    }
    
    func firstWhereMetaDataValueFor(key: MetaDataKey, notEquals value: MetaData.Value) -> Element? {
        return firstWhere(metaDatavalue: value, forKey: key, condition: { $0 != $1 })
    }
    
    func firstWhereMetaDataValueFor(key: MetaDataKey, equals value: MetaData.Value) -> Element? {
        return firstWhere(metaDatavalue: value, forKey: key, condition: { $0 == $1 })
    }
    
    func firstWhere(metaDatavalue value: MetaDataCommonValue, forKey key: MetaDataKey, condition equality: @escaping (MetaDataCommonValue, MetaDataCommonValue) -> Bool) -> Element? {
        
        let mappedEquality: ((MetaData.Value?, MetaData.Value) -> Bool) = {
            guard let lhsUnmapped = $0, case let rhsUnmapped = $1 else { return false }
            guard let lhs = MetaDataCommonValue(rawValue: lhsUnmapped), let rhs = MetaDataCommonValue(rawValue: rhsUnmapped) else {
                return false
            }
            return equality(lhs, rhs)
        }
        
        return firstWhere(metaDatavalue: value.rawValue, forKey: key, condition: mappedEquality)
    }
    
    func firstWhereMetaDataValueFor(key: MetaDataKey, notEquals value: MetaDataCommonValue) -> Element? {
        return firstWhere(metaDatavalue: value, forKey: key, condition: { $0 != $1 })
    }
    
    func firstWhereMetaDataValueFor(key: MetaDataKey, equals value: MetaDataCommonValue) -> Element? {
        return firstWhere(metaDatavalue: value, forKey: key, condition: { $0 == $1 })
    }
}
