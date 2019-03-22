//
//  Macros.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// true when optimization is set to -Onone
var isDebug: Bool {
    return _isDebugAssertConfiguration()
}

internal var abstract: Never {
    fatalError("Override this")
}

internal var implementMe: Never {
    fatalError("Implement this")
}

internal func incorrectImplementation(_ reason: String?, _ file: String = #file, _ line: Int = #line) -> Never {
    let message: String
    let base = "Incorrect implementation, file: \(file), line: \(line)"
    if let reason = reason {
        message = "\(base), \(reason)"
    } else {
        message = base
    }
    fatalError(message)
}
