//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
