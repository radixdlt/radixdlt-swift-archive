//
//  UnencryptedData.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct UnencryptedData {
    public let metaData: [MetaDataKey: Any]
    public let payload: Data
    public let isFromEncryptedSource: Bool
}

public extension UnencryptedData {
    var encryptionState: DecryptedMessage.EncryptionState {
        if isFromEncryptedSource {
            return .decrypted
        } else {
            return .wasNotEncrypted
        }
    }
}
