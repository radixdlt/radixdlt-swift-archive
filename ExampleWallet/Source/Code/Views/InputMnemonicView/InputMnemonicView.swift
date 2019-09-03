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


struct InputMnemonicView {
    @ObservedObject private var viewModel: ViewModel

    init(language: Mnemonic.Language, strength: Mnemonic.Strength) {
        viewModel = ViewModel(language: language, strength: strength)
    }
}

// MARK: - View
extension InputMnemonicView: View {
    var body: some View {
        VStack {
            List(viewModel.inputWords) { inputMnemonicWord in
                InputMnemonicCell(mnemonicInput: inputMnemonicWord)
            }

            Button("Print words") {
                self.viewModel.debug()
            }
        }
    }
}

// MARK: - VIEWMODEL
extension InputMnemonicView {
    final class ViewModel: ObservableObject {

        fileprivate let inputWords: [MnemonicInput]

        fileprivate let mnemonicWordListMatcher: MnemonicWordListMatcher

        fileprivate let wordCount: Int

        init(language: Mnemonic.Language, strength: Mnemonic.Strength) {
            let mnemonicWordListMatcher = MnemonicWordListMatcher(language: language)
            self.wordCount = strength.wordCount
            self.inputWords = (0..<strength.wordCount).map { MnemonicInput(id: $0, wordMatcher: mnemonicWordListMatcher) }
            self.mnemonicWordListMatcher = mnemonicWordListMatcher
        }

        func debug() {
            print(inputWords)
        }

    }
}
