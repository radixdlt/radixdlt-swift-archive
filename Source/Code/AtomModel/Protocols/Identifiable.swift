//
//  Identifiable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol Identifiable {
    var identifier: ResourceIdentifier { get }
}
