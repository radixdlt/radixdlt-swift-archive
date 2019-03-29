//
//  AtomSubscriptionUpdate.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AtomSubscriptionUpdate: Decodable {
    public let atomEvents: [AtomEvent]
    public let subscriberId: String
    public let isHead: Bool
}
