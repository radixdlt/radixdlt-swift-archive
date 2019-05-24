//
//  AtomSubscription.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomSubscription: Decodable {
    case startOrCancel(AtomSubscriptionStartOrCancel)
    case update(AtomSubscriptionUpdate)
}

// MARK: - Decodable
public extension AtomSubscription {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .startOrCancel(try container.decode(AtomSubscriptionStartOrCancel.self))
        } catch {
            self = .update(try container.decode(AtomSubscriptionUpdate.self))
        }
    }
}

public extension AtomSubscription {
    var startOrCancel: AtomSubscriptionStartOrCancel? {
        guard case .startOrCancel(let startOrCancel) = self else { return nil }
        return startOrCancel
    }
    
    var update: AtomSubscriptionUpdate? {
        guard case .update(let update) = self else { return nil }
        return update
    }
    
    var isStartOrCancel: Bool {
        return startOrCancel != nil
    }
    
    var isUpdate: Bool {
        return update != nil
    }
}
