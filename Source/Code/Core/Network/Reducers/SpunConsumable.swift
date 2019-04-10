//
//  SpunConsumable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias SpunConsumable = SpunAny<ConsumableTokens>

public struct SpunAny<P> {
    public let spin: Spin
    public let any: P
}
