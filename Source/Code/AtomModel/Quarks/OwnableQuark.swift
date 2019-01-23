//
//  OwnableQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct OwnableQuark: QuarkConvertible {
    private let owner: PublicKey
    public init(owner: PublicKey) {
        self.owner = owner
    }
}
