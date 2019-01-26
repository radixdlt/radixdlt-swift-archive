//
//  DsonConvertible.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol DsonConvertible: CustomStringConvertible {
    static var tag: DsonTag { get }
    associatedtype From: StringInitializable
    init(from: From) throws
}

extension String: DsonConvertible {
    public static var tag: DsonTag { return .string }
    public init(from: String) throws {
        self = from
    }
}
