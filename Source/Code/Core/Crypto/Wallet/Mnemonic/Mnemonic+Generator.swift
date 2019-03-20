//
//  Mnemonic+Generator.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

public extension Mnemonic {
    public struct Generator {
        
        public let strength: Strength
        public let language: Language
        
        public init(
            strength: Strength = .wordCountOf24,
            language: Language = .english
            ) {
            self.strength = strength
            self.language = language
        }
    }
}

// MARK: - Public
public extension Mnemonic.Generator {
    static var `default`: Mnemonic.Generator {
        return Mnemonic.Generator()
    }
}

// MARK: - From BitcoinKit
public extension Mnemonic.Generator {
    public func generate() throws -> Mnemonic {
        do {
            let words = try BitcoinKit.Mnemonic.generate(
                strength: strength.toBitcoinKitStrength,
                language: language.toBitcoinKitLanguage
            )
            assert(words.count == strength.wordCount)
            return try Mnemonic(strings: words, language: language)
        } catch let bitcoinKitMnemonicError as BitcoinKit.MnemonicError {
            throw Mnemonic.Error(fromBitcoinKitError: bitcoinKitMnemonicError)
        } catch {
            incorrectImplementation("BitcoinKit.Mnemonic.Error should have covered all possible errors, unexpected error: \(error), ")
        }
    }
}
