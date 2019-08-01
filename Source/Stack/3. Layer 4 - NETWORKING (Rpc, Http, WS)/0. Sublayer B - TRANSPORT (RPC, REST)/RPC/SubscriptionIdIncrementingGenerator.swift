//
//  SubscriptionIdIncrementingGenerator.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Subscriber Id Generator
public final class SubscriptionIdIncrementingGenerator {
    public static let shared = SubscriptionIdIncrementingGenerator()

    private var lastId: Int = 0
    
    private func getIdAndIncrease() -> Int {
        defer { lastId += 1 }
        return lastId
    }
    
}

public extension SubscriptionIdIncrementingGenerator {
    class func next() -> SubscriberId {
        let next = SubscriberId(validated: shared.getIdAndIncrease().description)
        return next
    }
}
