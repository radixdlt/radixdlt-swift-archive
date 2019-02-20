//
//  Nonce.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Nonce: Codable, Equatable {
    public typealias Value = Int64
    public let value: Value
    
    public init() {
        value = Int64.random(in: Value.min...Value.max)
    }
    
}
