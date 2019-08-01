//
//  AddressOfAccountDeriving.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-08-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AddressOfAccountDeriving {
    func addressOf(account: Account) -> Address
}

public extension AddressOfAccountDeriving where Self: Magical {
    func addressOf(account: Account) -> Address {
        return account.addressFromMagic(magic)
    }
}
