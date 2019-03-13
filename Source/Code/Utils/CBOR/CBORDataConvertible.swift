//
//  CBORDataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol CBORDataConvertible: DataConvertible, CBORConvertible, DSONPrefixSpecifying {}

// MARK: - CBORConvertible
public extension CBORDataConvertible {
    func toCBOR() -> CBOR {
        return CBOR.bytes(self, dsonPrefix: dsonPrefix)
    }
}
