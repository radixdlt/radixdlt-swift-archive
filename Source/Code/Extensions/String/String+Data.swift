//
//  String+Data.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension String {
    /// A data representation of the hexadecimal bytes in this string.
    /// credits: https://stackoverflow.com/a/52600783
    func hexDecodedData() -> Data {
        // Get the UTF8 characters of this string
        let chars = Array(utf8)
        
        // Keep the bytes in an UInt8 array and later convert it to Data
        var bytes = [UInt8]()
        bytes.reserveCapacity(count / 2)
        
        // Grab two characters at a time, map them and turn it into a byte
        for index in stride(from: 0, to: count, by: 2) {
            let index1 = Int(chars[index] & 0x1F ^ 0x10)
            let index2 = Int(chars[index + 1] & 0x1F ^ 0x10)
            bytes.append(utf8LookupTable[index1] << 4 | utf8LookupTable[index2])
        }
        
        return Data(bytes)
    }
}

// It is a lot faster to use a lookup map instead of strtoul
private let utf8LookupTable: [UInt8] = [
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
    0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
    0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
]
