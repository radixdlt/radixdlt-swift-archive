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
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: - View
extension BackUpMnemonicScreen: Screen {
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.words) { word in
                    Text(word.indexedWord)
                }.listStyle(GroupedListStyle())

                NavigationLink(destination: viewModel.makeDestination()) {
                    Text("Confirm").buttonStyleEmerald()
                }
            }.navigationBarTitle("Back up mnemonic")
        }
    }
}

// MARK: - ViewModel
typealias BackUpMnemonicViewModel = BackUpMnemonicScreen.ViewModel
extension BackUpMnemonicScreen {
    final class ViewModel: ObservableObject {
        fileprivate let securePersistence: SecurePersistence
        private let dismissClosure: Done
        init(securePersistence: SecurePersistence, dismiss: @escaping Done) {

            self.securePersistence = securePersistence
            self.dismissClosure = dismiss
        }
    }
}

private extension BackUpMnemonicScreen.ViewModel {
    var mnemonic: Mnemonic {
        guard let mnemonic = securePersistence.mnemonic else {
            incorrectImplementation("Should have mnemonic")
        }
        return mnemonic
    }

    var words: [MnemonicWord] {
        return mnemonic.words.map { $0.value }.enumerated().map {
            MnemonicWord(id: $0.offset, word: $0.element)
        }
    }

    func makeDestination() -> AnyScreen {
        AnyScreen(
            ConfirmMnemonicScreen()
                .environmentObject(
                    ConfirmMnemonicViewModel(
                        securePersistence: securePersistence,
                        dismiss: dismissClosure
                    )
            )
        )
    }
}
