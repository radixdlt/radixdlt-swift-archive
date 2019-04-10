//
//  AtomQuery.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AtomQuery: Encodable {
    public let address: Address
}

// MARK: - Encodable
public extension AtomQuery {
    enum CodingKeys: CodingKey {
        case address
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address.base58, forKey: .address)
    }
}
