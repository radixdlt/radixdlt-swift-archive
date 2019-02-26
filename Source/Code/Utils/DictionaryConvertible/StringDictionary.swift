//
//  StringDictionary.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct StringDictionary: Decodable {
    private let values: [String: String]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringMap = try container.decode([String: PrefixedStringWithValue].self)
        self.values = stringMap.mapValues { $0.stringValue }
    }
    
    func mapKeys<Key>(transform: (String) throws -> Key) throws -> [Key: String] where Key: Hashable {
        return try [Key: String](uniqueKeysWithValues: values.map {
            (
                try transform($0.key),
                $0.value
            )
        })
    }
}
