//
//  AtomSubscription.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomSubscription: Decodable {
    case start(AtomSubscriptionStart)
    case update(AtomSubscriptionUpdate)
    case cancel(AtomSubscriptionCancel)
}

// MARK: - Decodable
public extension AtomSubscription {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .start(try container.decode(AtomSubscriptionStart.self))
        } catch {
            do {
                self = .cancel(try container.decode(AtomSubscriptionCancel.self))
            } catch {
                self = .update(try container.decode(AtomSubscriptionUpdate.self))
            }
        }
    }
}
