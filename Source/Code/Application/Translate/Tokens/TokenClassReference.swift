//
//  TokenClassReference.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenClassReference: Codable, CustomStringConvertible, Equatable, Hashable {
    public static let subUnitsExponent = 18
    public static let subUnits = BigUnsignedInt(10).power(TokenClassReference.subUnitsExponent)
    
    public let address: Address
    public let symbol: String
    
    public init(address: Address, symbol: String) {
        self.address = address
        self.symbol = symbol
    }
}

public extension TokenClassReference {
    init(identifier: ResourceIdentifier) {
        self.init(address: identifier.address, symbol: identifier.unique)
    }
}

// MARK: - Public
public extension TokenClassReference {
    var path: String {
        return "\(address)/\(ResourceType.tokenClass.rawValue)/\(symbol)"
    }
}

// MARK: - Hashable
public extension TokenClassReference {
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

// MARK: - CustomStringConvertible
public extension TokenClassReference {
    var description: String {
        return path
    }
}
