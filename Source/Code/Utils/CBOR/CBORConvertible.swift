//
//  CBORConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

public typealias DSON = Data
public extension CBOREncodable {
    func toDSON() -> DSON {
        return encode().asData
    }
}

public protocol CBORConvertible: CBOREncodable {
    func toCBOR() -> CBOR
}

// MARK: - Conformance
extension Int: CBORConvertible {
    public func toCBOR() -> CBOR {
        return CBOR(integerLiteral: self)
    }
}
