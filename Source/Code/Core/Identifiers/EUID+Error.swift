//
//  EUID+Error.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension EUID {
    public enum Error: Swift.Error {
        case tooManyBytes(expected: Int, butGot: Int)
        case tooFewBytes(expected: Int, butGot: Int)
    }
}
