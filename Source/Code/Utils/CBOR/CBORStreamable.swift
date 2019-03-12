//
//  CBORStreamable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

public typealias CBORStreamable = CBOREncodable & KeyValueSpecifying

public enum Order {
    case asending
    case descending
}

public extension Sequence {
  
    func sorted<Property>(by keyPath: KeyPath<Element, Property>, order: Order = .asending) -> [Element] where Property: Comparable {
        return sorted(by: {
            let lhs = $0[keyPath: keyPath]
            let rhs = $1[keyPath: keyPath]
            switch order {
            case .asending: return lhs < rhs
            case .descending: return lhs > rhs
            }
        })
    }
}

public extension CBOREncodable where Self: KeyValueSpecifying {
    /// Radix type "map", according to this: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
    /// Format is this:
    /// 0xbf (encodeMapStreamStart)
    /// [propertyName (CBOREncoded) + propertyValue (CBOREncoded)] for each property
    /// 0xff (encodeStreamEnd)
    public func encode() -> [UInt8] {
        return [
            CBOR.encodeMapStreamStart(),
            keyValues.sorted(by: \.key)
            .flatMap {
                $0.cborEncodedKey() + $0.encode()
            },
            CBOR.encodeStreamEnd()
            ].flatMap { $0 }
    }
}
