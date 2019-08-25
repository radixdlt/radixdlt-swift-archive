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

import RadixSDK

extension Mnemonic: Codable {

    enum CodingKeys: Int, CodingKey {
        case numberOfWords
        case language
        case words
    }

    private static var separator: String { "," }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let wordsAsString = self.words.map { $0.value }.joined(separator: Mnemonic.separator)
        try container.encode(wordsAsString, forKey: .words)
        try container.encode(self.language.rawValue, forKey: .language)
        try container.encode(self.words.count, forKey: .numberOfWords)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let wordsAsString = try container.decode(String.self, forKey: .words)
        let words = wordsAsString.components(separatedBy: Mnemonic.separator).map(Mnemonic.Word.init(value:)) // { Mnemonic.Word($0) }
        let numberOfWords = try container.decode(Int.self, forKey: .numberOfWords)
        guard words.count == numberOfWords else {
            fatalError("incorrect number of words")
        }
        let languageRaw = try container.decode(String.self, forKey: .language)
        guard let language = Language(rawValue: languageRaw) else {
            fatalError("failed to create language")
        }
        self.init(words: words, language: language)
    }
}
