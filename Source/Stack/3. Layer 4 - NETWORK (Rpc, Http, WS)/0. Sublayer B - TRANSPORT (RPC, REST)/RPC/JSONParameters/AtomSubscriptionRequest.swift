//
//  AtomSubscriptionRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AtomSubscriptionRequest: Encodable {
    public let subscriberId: SubscriberId
    public let query: AtomQuery
    
    public init(query: AtomQuery, subscriberId: SubscriberId) {
        self.query = query
        self.subscriberId = subscriberId
    }
}

// MARK: Convenience init
public extension AtomSubscriptionRequest {
    init(address: Address, subscriberId: SubscriberId) {
        self.init(query: AtomQuery(address: address), subscriberId: subscriberId)
    }
}


public struct UnsubscriptionRequest: Encodable {
    public let subscriberId: SubscriberId
    
    public init(subscriberId: SubscriberId) {
        self.subscriberId = subscriberId
    }
}
