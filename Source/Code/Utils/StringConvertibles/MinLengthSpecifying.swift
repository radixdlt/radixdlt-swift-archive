//
//  MinLengthSpecifying.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol MinLengthSpecifying: LowerBound {
    static var minLength: Int { get }
}

public extension MinLengthSpecifying {
    static var minValue: Int {
        return minLength
    }
}
