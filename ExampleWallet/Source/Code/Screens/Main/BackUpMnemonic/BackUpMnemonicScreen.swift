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

struct BackUpMnemonicScreen {

    private let mnemonicToBackUp: Mnemonic
    private let isPresentingBackUpFlow: Binding<Bool>

    init(mnemonicToBackUp: Mnemonic, isPresentingBackUpFlow: Binding<Bool>) {
        self.mnemonicToBackUp = mnemonicToBackUp
        self.isPresentingBackUpFlow = isPresentingBackUpFlow
    }
}

// MARK: - View
extension BackUpMnemonicScreen: View {
    var body: some View {
        NavigationView {
            VStack {
                List(words) { word in
                    Text(word.indexedWord)
                }.listStyle(GroupedListStyle())

                NavigationLink(destination:
                    ConfirmMnemonicScreen(isPresentingBackUpFlow: self.isPresentingBackUpFlow)
                        .environmentObject(ConfirmMnemonicScreen.ViewModel(mnemonicToBackUp: mnemonicToBackUp))
                ) {
                    Text("Confirm").buttonStyleEmerald()
                }
            }.navigationBarTitle("Back up mnemonic")
        }
    }
}

private extension BackUpMnemonicScreen {

    var words: [MnemonicWord] {
        return mnemonicToBackUp.words.map { $0.value }.enumerated().map {
            MnemonicWord(id: $0.offset, word: $0.element)
        }
    }

}
