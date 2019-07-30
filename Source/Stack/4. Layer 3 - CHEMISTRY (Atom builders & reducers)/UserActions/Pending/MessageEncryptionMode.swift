//
//  MessageEncryptionMode.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum MessageEncryptionMode {
    case encrypt(onlyDecryptableBy: [Ownable])
    case plainText
}

public extension MessageEncryptionMode {
    var isEncryptionUsed: Bool {
        switch self {
        case .encrypt: return true
        case .plainText: return false
        }
    }
}
