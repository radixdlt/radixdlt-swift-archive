//
//  Signable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol Signable {
    var signableData: Data { get }
}

public protocol SignableConvertible: Signable {
    var signable: Signable { get }
}

public extension SignableConvertible {
    var signableData: Data {
        return signable.signableData
    }
}
