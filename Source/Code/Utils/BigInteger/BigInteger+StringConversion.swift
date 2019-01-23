//
//  BigInteger+StringConversion.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension BigInteger {
    
    func toHexString(uppercased: Bool = true) -> HexString {
        let string = toString(uppercased: uppercased, radix: 16)
        do {
            return try HexString(string: string)
        } catch {
            incorrectImplementation("Should always be able to create HexString, error: \(error)")
        }
    }
    
    func toDecimalString(uppercased: Bool = true) -> String {
        return toString(uppercased: uppercased, radix: 10)
    }
    
    func toString(uppercased: Bool = true, radix: Int) -> String {
        let stringRepresentation = String(self, radix: radix)
        guard uppercased else { return stringRepresentation }
        return stringRepresentation.uppercased()
    }
    
    /// Returns this integer as `Data` of `length`, if `length` is greater
    /// than the number itself, we pad empty bytes.
    func toData(minByteCount: Int? = nil) -> Data {
        var hexString = toHexString().value
        if let minByteCount = minByteCount {
            // each byte is represented as two hexadecimal chars
            let minStringLength = 2 * minByteCount
            while hexString.count < minStringLength {
                hexString = "0" + hexString
            }
        }
        return Data(hex: hexString)
    }
}
