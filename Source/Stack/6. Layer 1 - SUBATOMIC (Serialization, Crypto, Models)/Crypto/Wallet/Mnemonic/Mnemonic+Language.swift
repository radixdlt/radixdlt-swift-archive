//
//  Mnemonic+Language.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Mnemonic {
    enum Language: String {
        case english
    }
}

extension Mnemonic.Language: CaseIterable {}
extension Mnemonic.Language: Equatable {}

// MARK: - To BitcoinKit
import BitcoinKit
internal extension Mnemonic.Language {
    var toBitcoinKitLanguage: BitcoinKit.Mnemonic.Language {
        switch self {
        case .english: return .english
        }
    }
}
