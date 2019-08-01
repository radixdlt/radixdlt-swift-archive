//
//  NodeAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol NodeAction {
    var node: Node { get }
}

public extension NodeAction {
    var node: Node { abstract() }
}
