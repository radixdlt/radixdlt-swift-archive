//
//  Balance.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Balance: Comparable {
    public let amount: Granularity
}

// MARK: - Comparable
public extension Balance {
    static func < (lhs: Balance, rhs: Balance) -> Bool {
        return lhs.amount < rhs.amount
    }
}
