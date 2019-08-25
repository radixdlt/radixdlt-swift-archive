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

// MARK: - ViewModel
protocol IdentityCreationViewModel {
    func generateNewMnemonic()
    var mnemonic: Mnemonic? { get }
}

// MARK: - IdentityCreationScreen
struct IdentityCreationScreen<ViewModel> where ViewModel: IdentityCreationViewModel & ObservableObject {
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: - View
extension IdentityCreationScreen: Screen {
    var body: some View {
        Group {
            if viewModel.mnemonic != nil {
                viewModel.mnemonic.map { mnemonic in
                    Text("Mnemonic: \(mnemonic.description)")
                }
            } else {
                Text("Creating Mnemonic")
            }
        }
        .onAppear { self.viewModel.generateNewMnemonic() }
    }
}

// MARK: - ViewModel Default
final class DefaultIdentityCreationViewModel: IdentityCreationViewModel & ObservableObject {

    let objectWillChange: PassthroughSubject<Void, Never>
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
}

extension DefaultIdentityCreationViewModel {

    var mnemonic: Mnemonic? {
        get {
            keychainStore.mnemonic
        }
        set {
            keychainStore.mnemonic = newValue
        }
    }

    // Assume async
    func generateNewMnemonic() {
        do {
            mnemonic = try mnemonicGenerator.generate()
        } catch { incorrectImplementationShouldAlwaysBeAble(to: "Generate mnemonic", error) }
    }
}
