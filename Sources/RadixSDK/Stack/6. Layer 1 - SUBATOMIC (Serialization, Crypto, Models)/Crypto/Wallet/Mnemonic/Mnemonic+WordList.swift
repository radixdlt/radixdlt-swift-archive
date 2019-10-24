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
import BitcoinKit

public extension Mnemonic {
    enum WordList {}
}

public extension Mnemonic.WordList {

    static func forLanguage(_ language: Mnemonic.Language) -> [Mnemonic.Word] {
        return BitcoinKit.Mnemonic.wordList(for: language.toBitcoinKitLanguage).map(Mnemonic.Word.init(value:))
    }

    static var english: [Mnemonic.Word] {
        return forLanguage(.english)
    }

    static var spanish: [Mnemonic.Word] {
        return forLanguage(.spanish)
    }

    static var french: [Mnemonic.Word] {
        return forLanguage(.french)
    }

    static var italian: [Mnemonic.Word] {
        return forLanguage(.italian)
    }

    static var korean: [Mnemonic.Word] {
        return forLanguage(.korean)
    }

    static var japanese: [Mnemonic.Word] {
        return forLanguage(.japanese)
    }

    static var chineseSimplified: [Mnemonic.Word] {
        return forLanguage(.chineseSimplified)
    }

    static var chineseTraditional: [Mnemonic.Word] {
        return forLanguage(.chineseTraditional)
    }
}
