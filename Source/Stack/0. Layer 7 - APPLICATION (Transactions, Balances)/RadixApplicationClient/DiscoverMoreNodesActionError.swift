//
//  DiscoverMoreNodesActionError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-08-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct DiscoverMoreNodesActionError: NodeAction {
    public let reason: Swift.Error
}
