//
//  DSONEncodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

// Trick so that we do not have to import `SwiftCBOR` in a lot of places
public typealias CBOR = SwiftCBOR.CBOR
public extension CBOR {
    static func int64(_ int: Int64) -> CBOR {
        if int < 0 {
            return CBOR.negativeInt(UInt64(abs(int)))
        } else {
            return CBOR.unsignedInt(UInt64(int))
        }
    }
}
public typealias CBOREncodable = SwiftCBOR.CBOREncodable

public typealias DSON = Data

public protocol DSONEncodable {
    func toDSON(output: DSONOutput) throws -> DSON
}

public extension CBOREncodable where Self: CBOREncodable {
    func toDSON(output: DSONOutput = .default) throws -> DSON {
        return encode().asData
    }
}
