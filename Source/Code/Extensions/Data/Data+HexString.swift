//
//  Data+HexString.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Data {
    // swiftlint:disable function_body_length
    /// A hexadecimal string representation of the bytes.
    /// credits: https://stackoverflow.com/a/52600783
    func asHexString(uppercased: Bool = false) -> String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)
        
        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }
        
        let hexString = String(utf16CodeUnits: hexChars, count: hexChars.count)
        
        if uppercased {
            return hexString.uppercased()
        } else {
            return hexString
        }
    }
    // swiftlint:enable function_body_length
}
