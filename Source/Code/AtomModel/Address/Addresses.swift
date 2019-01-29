//
//  Addresses.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Addresses: Equatable, Codable, ExpressibleByArrayLiteral, Collection {
    
    public typealias Element = Address
    public let addresses: [Element]
    public init(addresses: [Element] = []) {
        self.addresses = addresses
    }
}

// MARK: - Codable
public extension Addresses {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let addresses = try container.decode([Dson<Address>].self)
        self.init(addresses: addresses.map { $0.value })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(addresses)
    }
}

// MARK: - Collection
public extension Addresses {
    typealias Index = Array<Element>.Index
    var startIndex: Index {
        return addresses.startIndex
    }
    var endIndex: Index {
        return addresses.endIndex
    }
    subscript(position: Index) -> Element {
        return addresses[position]
    }
    func index(after index: Index) -> Index {
        return addresses.index(after: index)
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension Addresses {
    init(arrayLiteral addresses: Element...) {
        self.init(addresses: addresses)
    }
}
