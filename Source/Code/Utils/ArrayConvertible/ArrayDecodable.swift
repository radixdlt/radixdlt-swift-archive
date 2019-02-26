//
//  ArrayDecodable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol ArrayDecodable: Codable, ArrayConvertible where Element: Decodable {}

public extension ArrayDecodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(elements: try container.decode([Element].self))
    }
}
