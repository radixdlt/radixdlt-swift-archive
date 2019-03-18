//
//  DataConvertible+Concatenation+Operators.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public func + (lhs: DataConvertible, rhs: Byte) -> Data {
    return Data(bytes: lhs.bytes + [rhs])
}

public func + (lhs: Byte, rhs: DataConvertible) -> Data {
    return Data(bytes: [lhs] + rhs.bytes)
}
