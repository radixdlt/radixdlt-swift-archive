//
//  JSONRPCMethodSubmitAtomAndSubscribe.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import JSONRPCKit

public struct AtomSubmitAndSubscribeRequest: Encodable {
//    public func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
//        return [
//            EncodableKeyValue(key: .atom, value: atom),
//            EncodableKeyValue(key: .subscriberId, value: subscriberId)
//        ]
//    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(atom, forKey: .atom)
        try container.encode(subscriberId, forKey: .subscriberId)
    }
    
    public enum CodingKeys: String, CodingKey {
        case serializer
        case atom, subscriberId
    }
    
    public let subscriberId: String
    public let atom: Atom
    
    public init(atom: Atom, subscriberId: String? = nil) {
        self.atom = atom
        self.subscriberId = subscriberId ?? SubscriptionIdIncrementingGenerator.next()
    }
}

public struct JSONRPCMethodSubmitAtomAndSubscribe: JSONRPCKit.Request {
    public typealias Response = AtomSubscription
    public let method = "Universe.submitAtomAndSubscribe"
    
    private let submitRequest: AtomSubmitAndSubscribeRequest
    
    public init(submitRequest: AtomSubmitAndSubscribeRequest) {
        self.submitRequest = submitRequest
    }
}

// MARK: - JSONRPCKit.Request
public extension JSONRPCMethodSubmitAtomAndSubscribe {
    var parameters: Encodable? {
        return submitRequest
    }
}

// MARK: - Convenience Init
public extension JSONRPCMethodSubmitAtomAndSubscribe {
    init(atom: Atom) {
        self.init(submitRequest: AtomSubmitAndSubscribeRequest(atom: atom))
    }
}
