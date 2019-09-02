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
//    @ObservedObject private var viewModel = ViewModel()
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

//private extension RestoreAccountChooseLanguageScreen {
//    var selectableLanguages: [Mnemonic.Language] {  }
//
//}

private extension Mnemonic.Language {
    static var indexOfEnglish: Int {
        guard let indexOfEnglish = Mnemonic.Language.allCases.firstIndex(of: .english) else {
            incorrectImplementation("'English' should be present in `Mnemonic.Language.allCases`")
        }
        return indexOfEnglish
    }
}

//// MARK: - VIEW MODEL
//extension RestoreAccountScreen {
//    final class ViewModel: ObservableObject {
//        @Published fileprivate var languageSelectionIndex = 0
//    }
//}


struct RestoreAccountChooseMnemonicStrenghtScreen {
    private let language: Mnemonic.Language
    init(language: Mnemonic.Language) {
        self.language = language
    }
}

extension RestoreAccountChooseMnemonicStrenghtScreen: View {
    var body: some View {
        VStack {
            Text("Strength of mnemonic")
            List(Mnemonic.Strength.allCases) { strength in
                NavigationLink(destination: InputMnemonicView(language: self.language, strength: strength)) {
                    Text("Word count of #\(strength.wordCount)")
                }
            }
        }
    }
}

//private extension RestoreAccountChooseMnemonicStrenghtScreen {
//    var selectableStrengths: [Mnemonic.Language] { Mnemonic.Language.allCases }
//
//    var selectedLanguage: Mnemonic.Language { selectableLangauge[languageSelectionIndex] }
//
//}
