//
//  IdentifiableQuark.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct IdentifiableQuark: QuarkConvertible {
    public let identifier: ResourceIdentifier
    
    public init(identifier: ResourceIdentifier) {
        self.identifier = identifier
    }
}

// MARK: - Codable
public extension IdentifiableQuark {
    public enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try container.decode(Dson<ResourceIdentifier>.self, forKey: .identifier).value
    }
}
