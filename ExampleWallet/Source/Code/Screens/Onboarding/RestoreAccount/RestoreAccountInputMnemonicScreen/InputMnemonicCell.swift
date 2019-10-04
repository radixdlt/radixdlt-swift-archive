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

struct InputMnemonicCell {
    @ObservedObject var viewModel: InputMnemonicViewModel

    private let id: Int

    init(mnemonicInput: MnemonicInput) {
        self.id = mnemonicInput.id
        
        self.viewModel = InputMnemonicViewModel(
            wordSubject: mnemonicInput.wordSubject,
            mnemonicWordListMatcher: mnemonicInput.mnemonicWordListMatcher
        )
        
    }
    
}

extension InputMnemonicCell: View {
    var body: some View {
        VStack {
            TextField("\(self.id + 1)", text: $viewModel.displayedWord)
            mnemonicHintView
        }
    }
}

private extension InputMnemonicCell {
    var mnemonicHintView: some View {
        MnemonicHintView(viewModel: mnemonicHintViewModel)
    }

    var mnemonicHintViewModel: MnemonicHintView.ViewModel {
        return MnemonicHintView.ViewModel(
            wordSubject: viewModel.wordSubject,
            mnemonicWordListMatcher: viewModel.mnemonicWordListMatcher
        )
    }
}

class InputMnemonicViewModel: ObservableObject {
    let wordSubject: CurrentValueSubject<String, Never>
    let mnemonicWordListMatcher: MnemonicWordListMatcher

    var displayedWord: String {
        set {
            print("input from textview: \(newValue)")
            self.wordSubject.send(newValue)
        }
        get {
            wordSubject.value
        }
    }

    private var cancellables = Set<AnyCancellable>()

    let objectWillChange = PassthroughSubject<Void, Never>()

    init(wordSubject: CurrentValueSubject<String, Never>, mnemonicWordListMatcher: MnemonicWordListMatcher) {
        self.wordSubject = wordSubject
        self.mnemonicWordListMatcher = mnemonicWordListMatcher
        wordSubject.removeDuplicates().eraseMapToVoid().subscribe(objectWillChange).store(in: &cancellables)
    }
}
