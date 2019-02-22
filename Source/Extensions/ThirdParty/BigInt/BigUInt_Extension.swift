//
//  BigUInt_Extension.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import BigInt

public extension BigUInt {
    init?(hex: String) {
        self.init(hex, radix: 16)
    }
}
