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
import RadixSDK

// MARK: - ViewModel
final class MnemonicWordListMatcher {

    fileprivate let wordList: [Mnemonic.Word]

    init(language: Mnemonic.Language) {
        self.wordList = Mnemonic.WordList.forLanguage(language)
    }
}

// MARK: SearchResult
extension MnemonicWordListMatcher {
    enum SearchResult {
        case perfectlyMatches(Mnemonic.Word)
        case candidates([Mnemonic.Word])
    }
}

// MARK: Methods
extension MnemonicWordListMatcher {
    func wordMatching(string: String?, minimumCharacterCount: Int = 2) -> SearchResult? {

        // TODO optimize this, using a dictionary and "fuzzy" search
        guard let needle = string, needle.count >= minimumCharacterCount else { return nil }

        func isMatch(_ word: Mnemonic.Word, requirePerfectMatch: Bool = false) -> Bool {
            let candidate = word.value.lowercased()
            let needleIgnoreCase = needle.lowercased()
            if requirePerfectMatch {
                return candidate == needleIgnoreCase
            } else {
                return candidate.starts(with: needleIgnoreCase)
            }
        }

        let result = wordList.filter { isMatch($0) }
        let searchResult: SearchResult

        // If we have an exact match, no need to suggest the word
        if result.count == 1, let singleCandidate = result.first, isMatch(singleCandidate, requirePerfectMatch: true) {
            searchResult = .perfectlyMatches(singleCandidate)
        } else {
            searchResult = .candidates(result)
        }

//        print("🔎: '\(needle)' => \(searchResult)")
        return searchResult
    }
}
