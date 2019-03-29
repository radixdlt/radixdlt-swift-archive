//
//  Ownable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol PublicKeyOwner {
    var publicKey: PublicKey { get }
}

public protocol Ownable {
    var address: Address { get }
}
