//
//  Secp256k1.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Secp256k1 {}
public extension Secp256k1 {
    // swiftlint:disable force_unwrap identifier_name
    static let order = BigUnsignedInt(hex: "FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141")!
    static let G = EllipticCurvePoint(
        x: BigUnsignedInt(hex: "79be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798")!,
        y: BigUnsignedInt(hex: "483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8")!
    )
    // swiftlint:enable force_unwrap identifier_name
}
