//
//  InvalidStringError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum InvalidStringError: Swift.Error {
    case invalidCharacters(expectedCharacters: CharacterSet, butGot: String)
    case tooManyCharacters(expectedAtMost: Int, butGot: Int)
    case tooFewCharacters(expectedAtLeast: Int, butGot: Int)
}
