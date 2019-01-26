//
//  DsonConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DsonConvertible: CustomStringConvertible {
    associatedtype From: StringInitializable
    init(from: From) throws
}

extension String: DsonConvertible {
    public init(from: String) throws {
        self = from
    }
}
