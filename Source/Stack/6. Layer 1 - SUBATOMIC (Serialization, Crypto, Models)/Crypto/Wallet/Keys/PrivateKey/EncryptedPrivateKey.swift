//
//  EncryptedPrivateKey.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

/// Holder encrypted private key data.
public struct EncryptedPrivateKey:
    DataConvertible,
    DataInitializable
{
    // swiftlint:enable colon opening_brace
    public let asData: Data
    public init(data: Data) {
        self.asData = data
    }
}
