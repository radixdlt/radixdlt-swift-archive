//
//  Signing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol Signing {
    var privateKey: PrivateKey { get }
}
