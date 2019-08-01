/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
import BitcoinKit

public extension Mnemonic {
    struct Generator {
        
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
    func generate() throws -> Mnemonic {
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
