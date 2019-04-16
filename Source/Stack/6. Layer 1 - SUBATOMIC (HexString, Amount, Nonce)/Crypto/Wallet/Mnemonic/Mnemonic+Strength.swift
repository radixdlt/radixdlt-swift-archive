//
//  Mnemonic+Strength.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Mnemonic {
    enum Strength: Int {
        case wordCountOf12 = 12
        case wordCountOf15 = 15
        case wordCountOf18 = 18
        case wordCountOf21 = 21
        case wordCountOf24 = 24
        
        var wordCount: Int {
            return rawValue
        }
    }
}

extension Mnemonic.Strength: CaseIterable {}

public extension Mnemonic.Strength {
    static func supports(wordCount: Int) -> Bool {
        return Mnemonic.Strength(rawValue: wordCount) != nil
    }
}

// MARK: - To BitcoinKit
import BitcoinKit
internal extension Mnemonic.Strength {
    var toBitcoinKitStrength: BitcoinKit.Mnemonic.Strength {
        switch self {
        case .wordCountOf12: return .default
        case .wordCountOf15: return .low
        case .wordCountOf18: return .medium
        case .wordCountOf21: return .high
        case .wordCountOf24: return .veryHigh
        }
    }
}
