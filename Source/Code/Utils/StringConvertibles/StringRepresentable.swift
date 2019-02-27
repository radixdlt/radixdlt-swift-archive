//
//  StringRepresentable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol StringRepresentable {
    var stringValue: String { get }
}

extension String: StringRepresentable {
    public var stringValue: String {
        return self
    }
}
