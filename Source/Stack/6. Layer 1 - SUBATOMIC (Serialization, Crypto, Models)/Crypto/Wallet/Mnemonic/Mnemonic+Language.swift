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
    enum Language: String {
        case english
        case italian
        case spanish
        case french
        case korean
        case japanese
        case chineseSimplified
        case chineseTraditional
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
        case .italian: return .italian
        case .spanish: return .spanish
        case .french: return .french
        case .korean: return .korean
        case .japanese: return .japanese
        case .chineseSimplified: return .simplifiedChinese
        case .chineseTraditional: return .traditionalChinese
        }
    }
}
