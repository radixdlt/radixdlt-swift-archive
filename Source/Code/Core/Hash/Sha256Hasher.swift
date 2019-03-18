//
//  Sha256Hasher.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Sha256Hasher: Hashing {
    public init() {}
    public func hash(data: Data) -> Data {
        return data.sha256()
    }
}
