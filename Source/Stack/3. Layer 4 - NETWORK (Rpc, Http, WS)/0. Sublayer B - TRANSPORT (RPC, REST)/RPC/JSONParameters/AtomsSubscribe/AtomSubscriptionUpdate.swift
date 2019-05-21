//
//  AtomSubscriptionUpdate.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol SubscriptionUpdate: Decodable {
    var subscriberId: String { get }
}

public enum AtomSubscriptionUpdate: SubscriptionUpdate {
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
    
    var subscriberId: String {
        switch self {
        case .submitAndSubscribe(let sas): return sas.subscriberId
        case .subscribe(let sub): return sub.subscriberId
        }
    }
    
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
    
    func mapTo<U: SubscriptionUpdateValue>(type: U.Type) -> U? {
        switch self {
        case .submitAndSubscribe(let sas): return sas as? U
        case .subscribe(let sub): return sub as? U
        }
    }
}

public protocol SubscriptionUpdateValue: SubscriptionUpdate {}

public struct AtomSubscriptionUpdateSubscribe: SubscriptionUpdateValue {
    public let atomEvents: [AtomEvent]
    public let subscriberId: String
    public let isHead: Bool
}

public extension AtomSubscriptionUpdateSubscribe {
    func toAtomUpdates() -> [AtomUpdate] {
        return atomEvents.enumerated().map {
            let atomEvent = $0.element
            let isHead = $0.offset == atomEvents.endIndex
            return AtomUpdate(atom: atomEvent.atom, action: atomEvent.type, isHead: isHead)
        }
    }
}

public struct AtomSubscriptionUpdateSubmitAndSubscribe: SubscriptionUpdateValue {
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
