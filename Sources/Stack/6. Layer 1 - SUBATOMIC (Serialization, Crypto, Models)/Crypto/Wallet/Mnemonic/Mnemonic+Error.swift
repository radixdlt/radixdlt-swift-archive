//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public extension Mnemonic {
    enum Error: Swift.Error, Equatable {
        case generatingRandomBytes
        case unsupportedByteCountOfEntropy(got: Int)
        case validation(Validation)
    }
}

public extension Mnemonic.Error {
    enum Validation: Swift.Error, Equatable {
        case badWordCount(expectedAnyOf: [Int], butGot: Int)
        case wordNotInList(String, language: Mnemonic.Language)
        case unableToDeriveLanguageFrom(words: [String])
        case checksumMismatch
    }
}

// MARK: - From BitcoinKit
import BitcoinKit
internal extension Mnemonic.Error {
    init(fromBitcoinKitError bitcoinKitMnemonicError: BitcoinKit.MnemonicError) {
        switch bitcoinKitMnemonicError {
        case .randomBytesError: self = .generatingRandomBytes
        case .unsupportedByteCountOfEntropy(let badEntropy): self = .unsupportedByteCountOfEntropy(got: badEntropy)
        case .validationError(let bitcoinKitInvalidMnemonicError):
            switch bitcoinKitInvalidMnemonicError {
            case .badWordCount(let expected, let butGot):
                self = .validation(.badWordCount(expectedAnyOf: expected, butGot: butGot))

            case .checksumMismatch:
                self = .validation(.checksumMismatch)

            case .unableToDeriveLanguageFrom(let words):
                self = .validation(.unableToDeriveLanguageFrom(words: words))

            case .wordNotInList(let word, let bitcoinKitLanguage):
                self = .validation(.wordNotInList(word, language: Mnemonic.Language(bitcoinKitLanguage: bitcoinKitLanguage)))
            }
        }
    }
}
