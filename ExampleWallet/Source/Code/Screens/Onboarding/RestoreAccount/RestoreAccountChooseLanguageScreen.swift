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

struct RestoreAccountChooseLanguageScreen {
    @State private var languageSelectionIndex = Mnemonic.Language.indexOfEnglish
}

// MARK: - VIEW
extension RestoreAccountChooseLanguageScreen: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Language of mnemonic")
                List(Mnemonic.Language.allCases) { language in
                    NavigationLink(destination: RestoreAccountChooseMnemonicStrenghtScreen(language: language)) {
                        Text("\(language.rawValue)")
                    }
                }
            }
        }
        .navigationBarTitle("Restore account")
    }
}

// MARK: Mnemonic.Language
private extension Mnemonic.Language {
    static var indexOfEnglish: Int {
        guard let indexOfEnglish = Mnemonic.Language.allCases.firstIndex(of: .english) else {
            incorrectImplementation("'English' should be present in `Mnemonic.Language.allCases`")
        }
        return indexOfEnglish
    }
}


