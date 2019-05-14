//
//  Amount+Sign+Check.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Amount {
    var isZero: Bool {
        return sign.isZero
    }
    
    var isPositive: Bool {
        return sign.isPositive
    }
    
    var isNegative: Bool {
        return sign.isNegative
    }
}
