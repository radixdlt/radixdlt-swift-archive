//
//  AtomSubscriptionUpdate.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomSubscriptionUpdate: Decodable {
    case subscribe(AtomSubscriptionUpdateSubscribe)
    case submitAndSubscribe(AtomSubscriptionUpdateSubmitAndSubscribe)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .subscribe(try container.decode(AtomSubscriptionUpdateSubscribe.self))
        } catch {
            self = .submitAndSubscribe(try container.decode(AtomSubscriptionUpdateSubmitAndSubscribe.self))
        }
    }
}

public extension AtomSubscriptionUpdate {
    var subscriptionUpdate: AtomSubscriptionUpdateSubscribe? {
        switch self {
        case .subscribe(let subscribeUpdate): return subscribeUpdate
        default: return nil
        }
    }
    
    var subscriptionFromSubmissionsUpdate: AtomSubscriptionUpdateSubmitAndSubscribe? {
        switch self {
        case .submitAndSubscribe(let submitAndSubscribe): return submitAndSubscribe
        default: return nil
        }
    }
}

public struct AtomSubscriptionUpdateSubscribe: Decodable {
    public let atomEvents: [AtomEvent]
    public let subscriberId: String
    public let isHead: Bool
}

public struct AtomSubscriptionUpdateSubmitAndSubscribe: Decodable {
    public let subscriberId: String
    public let value: State
    
    public enum State: String, Equatable, Decodable {
        var isCompletable: Bool {
            switch self {
            case .received: return false
            case .failed, .stored, .collision, .illegal, .unsuitablePeer, .validationError, .unknownError:
                return true
            }
        }
        case received = "RECEIVED"
        case failed = "FAILED"
        case stored = "STORED"
        case collision = "COLLISION"
        case illegal = "ILLEGAL"
        case unsuitablePeer = "UNSUITABLE_PEER"
        case validationError = "VALIDATION_ERROR"
        case unknownError = "UNKNOWN_ERROR"
    }
}
