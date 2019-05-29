//
//  Sharded.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias Shard = Int64

public protocol Sharded {
    var shard: Shard { get }
}
