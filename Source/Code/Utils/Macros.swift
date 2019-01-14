//
//  Macros.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal var abstract: Never {
    fatalError("Implement this")
}

internal func incorrectImplementation(_ reason: String?) -> Never {
    let message: String
    let base = "Incorrect implementation"
    if let reason = reason {
        message = "\(base), \(reason)"
    } else {
        message = base
    }
    fatalError(message)
}
