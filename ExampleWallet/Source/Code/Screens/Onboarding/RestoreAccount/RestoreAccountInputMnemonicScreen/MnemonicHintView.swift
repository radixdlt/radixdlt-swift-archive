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
import SwiftUI
import Combine
import RadixSDK

struct MnemonicHintView {

    @ObservedObject var viewModel: ViewModel
}

extension MnemonicHintView: View {
    var body: some View {
        GeometryReader { geometry in
            HStack {
                ForEach(self.viewModel.someOfTheFirstSuggestedMatchingWords.prefix(Int(geometry.size.width/70))) { suggestedWord in

                    // Button did not work
                    Text("\(suggestedWord.value)").onTapGesture {
                        self.viewModel.confirm(word: suggestedWord)
                    }
                    .padding([.top, .bottom])
                    .padding([.leading, .trailing], 8)
                    .foregroundColor(Color.white)
                    .background(Color.Radix.saphire)
                    .cornerRadius(5)
                }
            }
        }
        .frame(height: viewModel.someOfTheFirstSuggestedMatchingWords.isEmpty ? 0 : 100, alignment: .center)
    }
}

// MARK: - VIEWMODEL
extension MnemonicHintView {
    final class ViewModel: ObservableObject {

        @Published var someOfTheFirstSuggestedMatchingWords = [Mnemonic.Word]()

        private var cancellable: Cancellable?

        let wordSubject: CurrentValueSubject<String, Never>
        let mnemonicWordListMatcher: MnemonicWordListMatcher

        init(wordSubject: CurrentValueSubject<String, Never>, mnemonicWordListMatcher: MnemonicWordListMatcher) {
            self.wordSubject = wordSubject
            self.mnemonicWordListMatcher = mnemonicWordListMatcher

            cancellable = wordSubject
                .removeDuplicates(by: { $0.lowercased() == $1.lowercased() })
                .debounce(for: .milliseconds(30), scheduler: RunLoop.main)
                .subscribe(on: RunLoop.main)
                .sink { [weak self] wordInputString in
                    self?.userChangedInput(to: wordInputString)
            }
        }
    }
}

private extension MnemonicHintView.ViewModel {
    func confirm(word: Mnemonic.Word, dueToPerfectMatch: Bool = false) {
        wordSubject.send(word.value)
        print("confirmed word: '\(word.value)' (perfect match: \(dueToPerfectMatch))")
    }

    func userChangedInput(to wordInputString: String) {
        guard let searchResult = self.mnemonicWordListMatcher.wordMatching(string: wordInputString, minimumCharacterCount: 1) else {
            someOfTheFirstSuggestedMatchingWords = []

            return
        }

        switch searchResult {
        case .candidates(let candidates):
            someOfTheFirstSuggestedMatchingWords = candidates

        case .perfectlyMatches(let perfectMatch):
            someOfTheFirstSuggestedMatchingWords = []
            // that id to use? hmm... should probably not need any, refactor this
            confirm(word: perfectMatch, dueToPerfectMatch: true)
        }
    }
}

extension Mnemonic.Word: Swift.Identifiable {
    public var id: String { value }
}
