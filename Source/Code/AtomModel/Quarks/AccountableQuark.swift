//
//  AccountableQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt

public struct AccountableQuark: QuarkConvertible {
    public let addresses: Addresses
    public init(addresses: Addresses) {
        self.addresses = addresses
    }
}

public extension AccountableQuark {
    init(address: Address) {
        self.init(addresses: [address])
    }
}
