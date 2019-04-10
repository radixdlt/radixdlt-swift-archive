//
//  JSONRPCMethodAtomsSubscribe.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct JSONRPCMethodAtomsSubscribe: JSONRPCKit.Request {
    public typealias Response = AtomSubscription
    public let method = "Atoms.subscribe"
    
    private let subscriptionRequest: AtomSubscriptionRequest
    
    public init(subscriptionRequest: AtomSubscriptionRequest) {
        self.subscriptionRequest = subscriptionRequest
    }
}

// MARK: - JSONRPCKit.Request
public extension JSONRPCMethodAtomsSubscribe {
    var parameters: Encodable? {
        return subscriptionRequest
    }
}

// MARK: - Convenience Init
public extension JSONRPCMethodAtomsSubscribe {
    init(address: Address) {
        self.init(subscriptionRequest: AtomSubscriptionRequest(address: address))
    }
    
    init(query: AtomQuery) {
        self.init(subscriptionRequest: AtomSubscriptionRequest(query: query))
    }
}
