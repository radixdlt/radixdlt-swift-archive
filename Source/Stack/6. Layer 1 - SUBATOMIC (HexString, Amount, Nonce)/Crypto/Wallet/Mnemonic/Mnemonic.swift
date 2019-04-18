//
//  Mnemonic.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Mnemonic {
    
    public static let seperator: String = " "
    
    public let words: [Word]
    public let language: Language
    
    public init(words: [Word], language: Language) {
        assert(Strength.supports(wordCount: words.count), "Unexpected word length")
        self.words = words
        self.language = language
    }
}

// MARK: - Internal
internal extension Mnemonic {
    init(strings: [String], language: Language) throws {
        self.init(words: strings.map(Word.init(value:)), language: language)
    }
}

// MARK: - To BitcoinKit
import BitcoinKit
internal extension Mnemonic {
    var seed: Data {
        return BitcoinKit.Mnemonic.seed(mnemonic: words.map { $0.value })
    }
}
