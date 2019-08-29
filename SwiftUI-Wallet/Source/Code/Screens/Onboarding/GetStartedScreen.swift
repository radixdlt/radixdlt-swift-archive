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

struct GetStartedScreen {
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: - View
extension GetStartedScreen: Screen {
    var body: some View {
        NavigationView {
            VStack {

                Button("GetStarted.Button.ReceiveTransaction") {
                    self.viewModel.generateNewMnemonicAndProceedToMainScreen()
                }
                .buttonStyleEmerald()

                LabelledDivider(Text("GetStarted.Text.Or"))

                NavigationLink(destination: RestoreAccountScreen()) {
                    Text("GetStarted.Button.RestoreAccount").buttonStyleSaphire()
                }

            }.padding(20)
        }
    }
}

// MARK: - ViewModel
typealias GetStartedViewModel = GetStartedScreen.ViewModel
extension GetStartedScreen {
    final class ViewModel: ObservableObject {

        let objectWillChange: PassthroughSubject<Void, Never>
        fileprivate let preferences: Preferences
        fileprivate let securePersistence: SecurePersistence
        private let mnemonicGenerator: Mnemonic.Generator

        private let walletCreated: () -> Void

        init(
            preferences: Preferences,
            securePersistence: SecurePersistence,
            mnemonicGenerator: Mnemonic.Generator = .init(strength: .wordCountOf12, language: .english),
            walletCreated: @escaping () -> Void
        ) {
            self.preferences = preferences
            self.securePersistence  = securePersistence
            self.mnemonicGenerator = mnemonicGenerator
            self.objectWillChange = securePersistence.objectWillChange
            self.walletCreated = walletCreated
        }
    }

}

extension GetStartedScreen.ViewModel {
    func generateNewMnemonicAndProceedToMainScreen() {
        do {
            let newMnemonic = try mnemonicGenerator.generate()
            securePersistence.mnemonic = newMnemonic
            securePersistence.seedFromMnemonic = newMnemonic.seed
            walletCreated()
        } catch { incorrectImplementationShouldAlwaysBeAble(to: "Generate mnemonic", error) }
    }
}



#if DEBUG
struct GetStartedScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            GetStartedScreen()
                .environment(\.locale, Locale(identifier: "en"))

            GetStartedScreen()
                .environment(\.locale, Locale(identifier: "sv"))
        }
    }
}
#endif
