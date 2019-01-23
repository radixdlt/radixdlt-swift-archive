//
//  RandomData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias Byte = UInt8

internal func randomBytes(count: Int) -> [Byte]? {
    var bytes = [Byte](repeating: 0, count: count)
    guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
        return nil
    }
    return bytes
}

public extension Data {
    static func random(byteCount: Int) -> Data {
        var bytes: [Byte]! = nil
        while bytes == nil {
            bytes = randomBytes(count: byteCount)
        }
        return Data(bytes: bytes)
    }
}
