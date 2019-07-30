//
//  PutUniqueIdAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct PutUniqueIdAction: UserAction {}

public extension PutUniqueIdAction {
    var nameOfAction: UserActionName { return .putUnique }
}
