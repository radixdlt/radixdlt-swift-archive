//
//  Addresses.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Addresses: ArrayDecodable, Equatable {
    
    public let addresses: Set<Address>
    
    public init(addresses: Set<Address> = Set()) {
        self.addresses = addresses
    }
}

// MARK: - ArrayDecodable
public extension Addresses {
    public typealias Element = Address
    
    var elements: [Element] {
        return addresses.asArray
    }
    
    init(elements: [Element]) {
        self.init(addresses: elements.asSet)
    }
}
