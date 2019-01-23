//
//  FungibleQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BigInt

public struct FungibleQuark: QuarkConvertible {
    public enum FungibleType: String, Codable {
        case minted = "mint"
        case transferred = "transfer"
        case burned = "burn"
    }
    private let type: FungibleType
    private let plack: BigInt
    private let nonce: BigInt
    private let amount: BigUInt
}
