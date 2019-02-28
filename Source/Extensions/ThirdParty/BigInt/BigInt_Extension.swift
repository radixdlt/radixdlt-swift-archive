//
//  BigInt_Extension.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt

public extension BigSignedInt {
    public init(data: Data) {
        let hex = data.toHexString()
        guard let bigInt = BigSignedInt(hex, radix: 16) else {
            incorrectImplementation("Should always be able to create from hex")
        }
        self = bigInt
    }
}
