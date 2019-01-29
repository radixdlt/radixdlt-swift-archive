//
//  DataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DataConvertible: CustomStringConvertible {
    var asData: Data { get }
}

public extension DataConvertible {
    var hex: String {
        return asData.toHexString()
    }
    
    var unsignedBigInteger: BigUnsignedInt {
        return BigUnsignedInt(asData)
    }
}
