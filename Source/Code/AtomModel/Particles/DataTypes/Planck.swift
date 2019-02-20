//
//  Planck.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Planck: Codable, Equatable {
    public typealias Value = UInt64
    let value: Value
    
    public init() {
        let secondsSince1970 = Value(Date().timeIntervalSince1970)
        value = secondsSince1970/60 + 60
    }
}
