//
//  InvalidStringError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum InvalidStringError: Swift.Error, Equatable {
    case invalidCharacters(expectedCharacters: CharacterSet, butGot: String)
    case tooManyCharacters(expectedAtMost: Int, butGot: Int)
    case tooFewCharacters(expectedAtLeast: Int, butGot: Int)
    case lengthNotMultiple(of: Int, shortOf: Int)
}

public extension InvalidStringError {
    static func == (lhs: InvalidStringError, rhs: InvalidStringError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCharacters, .invalidCharacters): return true
        case (.tooManyCharacters, .tooManyCharacters): return true
        case (.tooFewCharacters, .tooFewCharacters): return true
        case (.lengthNotMultiple, .lengthNotMultiple): return true
        default: return false
        }
    }
}
