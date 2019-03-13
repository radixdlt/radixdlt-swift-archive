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

public typealias DSON = Data

public protocol DSONEncodable: CBOREncodable {
    func toDSON() -> DSON
}

public extension CBOREncodable {
    func toDSON() -> DSON {
        return encode().asData
    }
}
