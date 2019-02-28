//
//  Fungible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol Fungible {
    var tokenType: TokenType { get }
    var planck: Planck { get }
    var nonce: Nonce { get }
    var amount: Amount { get }
}
