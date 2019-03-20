//
//  Sha256TwiceHasher.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import CryptoSwift

public struct Sha256TwiceHasher: Hashing {
    public init() {}
    public func hash(data: Data) -> Data {
        return data.sha256().sha256()
    }
}
