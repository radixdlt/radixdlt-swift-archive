//
//  AtomSubscriptionUpdate.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol SubscriptionUpdate: PotentiallySubscriptionIdentifiable, Decodable {
    var subscriberId: SubscriberId { get }
}

public extension SubscriptionUpdate {
    var subscriberIdIfPresent: SubscriberId? { return subscriberId }
}

public struct AtomSubscriptionUpdate: SubscriptionUpdate {
    public let atomEvents: [AtomEvent]
    public let subscriberId: SubscriberId
    public let isHead: Bool
}

public extension AtomSubscriptionUpdate {
    func toAtomObservation() -> [AtomObservation] {
        return atomEvents.enumerated().flatMap { eventAtIndex -> [AtomObservation] in
            var observations: [AtomObservation] = [AtomObservation(eventAtIndex.element)]
            let isHead = eventAtIndex.offset == atomEvents.endIndex
            if isHead {
                observations.append(AtomObservation.head())
            }
            return observations
        }
    }
}
