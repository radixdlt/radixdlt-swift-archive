//
//  PrivateKey.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

public struct PrivateKey {

    internal let data: Data

    public init(data: Data) {
        self.data = data
    }
}
