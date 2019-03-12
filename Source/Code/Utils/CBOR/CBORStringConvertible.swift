//
//  CBORStringConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

public protocol CBORStringConvertible: StringConvertible, CBORConvertible {}

// MARK: - CBOREncodable
public extension CBORStringConvertible {
    // TODO can default conformance to `CBOREncodable` be moved to CBORConvertible
    func encode() -> [UInt8] {
        return toCBOR().encode()
    }
}

// MARK: - CBORConvertible
public extension CBORStringConvertible {
    func toCBOR() -> CBOR {
        return CBOR(stringLiteral: stringValue)
    }
}
