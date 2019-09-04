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

import SwiftUI
import RadixSDK
import Combine

struct RestoreAccountInputMnemonicScreen {

    @ObservedObject private var viewModel: ViewModel

    init(language: Mnemonic.Language, strength: Mnemonic.Strength) {
        viewModel = ViewModel(language: language, strength: strength)
    }
}

// MARK: - View
extension RestoreAccountInputMnemonicScreen: View {
    var body: some View {
        VStack {
            List(viewModel.inputWords) { inputMnemonicWord in
                InputMnemonicCell(mnemonicInput: inputMnemonicWord)
            }

            Button("Confirm") {
                self.viewModel.confirmMnemonic()
            }.enabled(viewModel.canConfirm)
        }
    }
}

// MARK: - VIEWMODEL
extension RestoreAccountInputMnemonicScreen {
    final class ViewModel: ObservableObject {

        fileprivate let inputWords: [MnemonicInput]

        fileprivate let mnemonicWordListMatcher: MnemonicWordListMatcher

        fileprivate let wordCount: Int

        private let _createMnemonic: (([Mnemonic.Word]) -> (Mnemonic, Bool))
        private let _words: () -> [Mnemonic.Word]?

        private var cancellables = Set<AnyCancellable>()

        @Published var isMnemonicChecksummed: Bool = false
        @Published var mnemonic: Mnemonic? = nil

        let objectWillChange = PassthroughSubject<Void, Never>()

        init(language: Mnemonic.Language, strength: Mnemonic.Strength) {
            let mnemonicWordListMatcher = MnemonicWordListMatcher(language: language)
            self.wordCount = strength.wordCount
            let inputWords = (0..<strength.wordCount).map { MnemonicInput(id: $0, wordMatcher: mnemonicWordListMatcher) }
            self.inputWords = inputWords
            self.mnemonicWordListMatcher = mnemonicWordListMatcher

            func createMnemonic(words: [Mnemonic.Word]) -> (Mnemonic, Bool) {
                let mnemonic = Mnemonic(words: words, language: language) { _, _ in }
                let isChecksummed: Bool = (try? Mnemonic.validateChecksummed(words: words, language: language)) ?? false
                return (mnemonic, isChecksummed)
            }

            self._createMnemonic = { createMnemonic(words: $0) }
            self._words = {
                let words = inputWords.map { $0.wordSubject.value }
                    .filter { !$0.isEmpty }
                    .map { Mnemonic.Word.init(value: $0) }
                    .filter { potentialWord in
                        Set(Mnemonic.WordList.forLanguage(language)).contains(potentialWord)
                    }
                guard words.count == strength.wordCount else { return nil /* not all words filled yet */ }
                return words
            }

            inputWords.forEach({ [unowned self] in $0.objectWillChange.subscribe(self.objectWillChange).store(in: &cancellables) })

            #if DEBUG
            inputWords[0].wordSubject.send("badge")
            inputWords[1].wordSubject.send("submit")
            inputWords[2].wordSubject.send("return")
            inputWords[3].wordSubject.send("inflict")
            inputWords[4].wordSubject.send("kangaroo")
            inputWords[5].wordSubject.send("position")
            inputWords[6].wordSubject.send("joke")
            inputWords[7].wordSubject.send("merit")
            inputWords[8].wordSubject.send("envelope")
            inputWords[9].wordSubject.send("term")
            inputWords[10].wordSubject.send("special")
//            inputWords[11].wordSubject.send("develop")

            // will create an address ending with: "laZBk"
            #endif
        }

        func confirmMnemonic() {
            guard let words = self.words else { return }
            let (mnemonic, isChecksummed) = createMnemonic(words: words)
            print("isChecksummed: \(isChecksummed)")
            self.isMnemonicChecksummed = isChecksummed
            self.mnemonic = mnemonic
        }

        var canConfirm: Bool {
            print("canConfirm: \(words != nil)")
            return words != nil
        }

        func createMnemonic(words: [Mnemonic.Word]) -> (Mnemonic, Bool) {
            _createMnemonic(words)
        }

        private var words: [Mnemonic.Word]? {
            return _words()
        }

    }
}
