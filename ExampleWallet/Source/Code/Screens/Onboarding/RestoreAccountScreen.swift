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

import RadixSDK

struct RestoreAccountScreen {
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: - View
extension RestoreAccountScreen: Screen {
    var body: some View {
        VStack {
            Text("Write your mnemonic")
            inputMnemonicView
        }
        .navigationBarTitle("Restore your Radix acount")
    }
}

private extension RestoreAccountScreen {
    var inputMnemonicView: some View {
        viewModel.makeInputMnemonicView()
    }
}

// MARK: - ViewModel
typealias RestoreAccountViewModel = RestoreAccountScreen.ViewModel

extension RestoreAccountScreen {
    final class ViewModel: ObservableObject {
        private let securePersistence: SecurePersistence

        fileprivate let mnemonicRestored: Done

        init(securePersistence: SecurePersistence, mnemonicRestored: @escaping Done) {
            self.securePersistence = securePersistence
            self.mnemonicRestored = mnemonicRestored
        }

    }
}

extension RestoreAccountViewModel {
    func makeInputMnemonicView() -> some View {
        InputMnemonicView().environmentObject(
            InputMnemonicViewModel { [unowned self] restoredMnemonic in
                self.securePersistence.seedFromMnemonic = restoredMnemonic.seed
                self.mnemonicRestored()
            }
        )
    }
}
