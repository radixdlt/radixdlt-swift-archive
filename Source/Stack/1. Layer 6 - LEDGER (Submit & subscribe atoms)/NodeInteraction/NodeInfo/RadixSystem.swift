//
//  RadixSystem.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct RadixSystem:
    RadixModelTypeStaticSpecifying,
    Codable,
    Equatable,
    Hashable
{

    // swiftlint:enable colon opening_brace
    
    public static let serializer = RadixModelType.radixSystem
    
    public let shards: ShardSpace
    
    public init(
        shards: ShardSpace
    ) {
        self.shards = shards
    }
}
