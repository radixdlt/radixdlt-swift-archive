//
//  BitArray+DataConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension BitArray: DataConvertible {
    public var asData: Data {
        return Data(toBytes())
    }

    public mutating func replace<R>(_ subrange: R, withBit bit: Bool) where R: RangeExpression, Index == R.Bound {
        let range = subrange.relative(to: self)
        for index in range {
            self[index] = bit
        }
    }
}

private extension BitArray {
    // From: https://stackoverflow.com/a/42738639/1311272
    private func toBytes() -> [Byte] {
        precondition(count % 8 == 0, "Bit array size must be multiple of 8")
        
        let numBytes = 1 + (count - 1) / 8
        var bytes = [Byte](repeating: 0, count: numBytes)
        
        for (index, bit) in enumerated() where bit == .one {
            bytes[index / 8] += Byte(1 << (7 - index % 8))
        }
        return bytes
    }
}

extension Bool {
    static var one: Bool {
        return true
    }
    static var zero: Bool {
        return false
    }
}
