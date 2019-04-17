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

public extension AtomSubscription {
    var start: AtomSubscriptionStart? {
        guard case .start(let start) = self else { return nil }
        return start
    }
    
    var update: AtomSubscriptionUpdate? {
        guard case .update(let update) = self else { return nil }
        return update
    }
    
    var cancel: AtomSubscriptionCancel? {
        guard case .cancel(let cancel) = self else { return nil }
        return cancel
    }
    
    var isStart: Bool {
        return start != nil
    }
    
    var isUpdate: Bool {
        return update != nil
    }
    
    var isCancel: Bool {
        return cancel != nil
    }
}
