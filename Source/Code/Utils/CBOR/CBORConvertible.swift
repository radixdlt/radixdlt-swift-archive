//
//  CBORConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol CBORConvertible: DSONEncodable, CBOREncodable {
    func toCBOR() -> CBOR
}

// MARK: - DSONEncodable
public extension CBORConvertible {
    func encode() -> [UInt8] {
        return toCBOR().encode()
    }
}

// MARK: - Conformance
extension Int: CBORConvertible {
    public func toCBOR() -> CBOR {
        return CBOR(integerLiteral: self)
    }
}
