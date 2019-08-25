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

struct IdentityCreationScreen {
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: - View
extension IdentityCreationScreen: Screen {
    var body: some View {
        Group {
            if viewModel.keychainStore.mnemonic != nil {
                viewModel.keychainStore.mnemonic.map { mnemonic in
                    Text("Mnemonic: \(mnemonic.description)")
                }
            } else {
                Text("Creating Mnemonic")
            }
        }
        .onAppear { self.viewModel.generateNewMnemonicWithDelay() }
    }
}

// MARK: - ViewModel
extension IdentityCreationScreen {
    final class ViewModel: ObservableObject {

        fileprivate let keychainStore: KeychainStore
        private let mnemonicGenerator: Mnemonic.Generator


        init(
            keychainStore: KeychainStore,
            mnemonicGenerator: Mnemonic.Generator = .init(strength: .wordCountOf24, language: .english)
        ) {
            self.keychainStore  = keychainStore
            self.mnemonicGenerator = mnemonicGenerator
            objectWillChange = keychainStore.objectWillChange
        }

        let objectWillChange: PassthroughSubject<Void, Never>

//        var mnemonic: Mnemonic? {
//            willSet {
//                objectWillChange.send()
//            }
//        }

    }
}

extension IdentityCreationScreen.ViewModel {

    // Assume async
    func generateNewMnemonic() {
        do {
            keychainStore.mnemonic = try mnemonicGenerator.generate()
        } catch { incorrectImplementationShouldAlwaysBeAble(to: "Generate mnemonic", error) }
    }

    func generateNewMnemonicWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.generateNewMnemonic()
        }
    }
}
