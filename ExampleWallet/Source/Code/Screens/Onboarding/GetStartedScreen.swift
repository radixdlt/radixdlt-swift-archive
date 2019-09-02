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

    @EnvironmentObject private var appState: AppState

    // TODO allow for selection of language and strength
    private let mnemonicGenerator = Mnemonic.Generator(strength: .wordCountOf12, language: .english)
}

// MARK: - View
extension GetStartedScreen: View {
    var body: some View {
        NavigationView {
            VStack {

                Button("GetStarted.Button.ReceiveTransaction") {
                    self.generateNewMnemonicAndProceedToMainScreen()
                }
                .buttonStyleEmerald()

                LabelledDivider(Text("GetStarted.Text.Or"))

                NavigationLink(destination: RestoreAccountChooseLanguageScreen()) {
                    Text("GetStarted.Button.RestoreAccount").buttonStyleSaphire()
                }

            }.padding(20)
        }
    }
}

private extension GetStartedScreen {
    func generateNewMnemonicAndProceedToMainScreen() {
        let newMnemonic = mnemonicGenerator.newMnemonic()
        appState.update().userDid.generate(mnemonic: newMnemonic)
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

private extension Mnemonic.Generator {
    func newMnemonic() -> Mnemonic {
        do {
            return try generate()
        } catch { incorrectImplementationShouldAlwaysBeAble(to: "Generate mnemonic", error) }
    }
}
