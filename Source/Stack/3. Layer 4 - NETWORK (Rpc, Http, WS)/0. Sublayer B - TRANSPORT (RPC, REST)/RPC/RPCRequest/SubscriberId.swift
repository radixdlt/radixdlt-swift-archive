//
//  SubscriberId.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SubscriberId: Hashable, Codable, ExpressibleByStringLiteral, StringConvertible {
    public let value: String
    
    public init(validated: String) {
        self.value = validated
    }
}

public extension SubscriberId {
    init(uuid: UUID) {
        self.init(validated: uuid.uuidString)
    }
}

public extension SubscriberId {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
