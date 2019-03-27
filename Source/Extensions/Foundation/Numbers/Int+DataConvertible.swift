//
//  Int+DataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension BinaryInteger {
    var asData: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Self>.size)
    }
}

extension UInt8: DataConvertible {}
extension Int8: DataConvertible {}

extension UInt16: DataConvertible {}
extension Int16: DataConvertible {}

extension UInt32: DataConvertible {}
extension Int32: DataConvertible {}

extension UInt64: DataConvertible {}
extension Int64: DataConvertible {}
