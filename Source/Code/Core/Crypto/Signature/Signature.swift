//
//  Signature.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Signature: Codable {
    //swiftlint:disable identifier_name
    public let r: BigUnsignedInt
    public let s: BigUnsignedInt
    //swiftlint:enable identifier_name
}
