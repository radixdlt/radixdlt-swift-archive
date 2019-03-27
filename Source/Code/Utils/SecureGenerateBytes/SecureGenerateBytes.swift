//
//  SecureGenerateBytes.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-03-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import Security

public func securelyGenerateBytes(count: Int) throws -> Data {
    var randomBytes = [UInt8](repeating: 0, count: count)
    let statusRaw = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes) as OSStatus
    let status = Status(status: statusRaw)
    guard status == .success else { throw status }
    return Data(randomBytes)
}
