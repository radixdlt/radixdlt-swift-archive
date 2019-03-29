//
//  AtomSubscriptionRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AtomSubscriptionRequest: Encodable {
    public let subscriberId: String
    public let query: AtomQuery
    
    public init(query: AtomQuery, subscriberId: String? = nil) {
        self.query = query
        self.subscriberId = subscriberId ?? SubscriptionIdIncrementingGenerator.next()
    }
}

// MARK: Convenience init
public extension AtomSubscriptionRequest {
    init(address: Address, subscriberId: String? = nil) {
        self.init(query: AtomQuery(address: address), subscriberId: subscriberId)
    }
}

// MARK: - Subscriber Id Generator
public extension AtomSubscriptionRequest {
    class SubscriptionIdIncrementingGenerator {
        private var lastId: Int = 0
        private func getIdAndIncrease() -> Int {
            defer { lastId += 1 }
            return lastId
        }
        private static let shared = SubscriptionIdIncrementingGenerator()
        public class func next() -> String {
            return shared.getIdAndIncrease().description
        }
    }
}
