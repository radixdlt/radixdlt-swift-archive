//
//  StringInitializable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol StringInitializable: Codable, CustomStringConvertible {
    init(string: String) throws
}
