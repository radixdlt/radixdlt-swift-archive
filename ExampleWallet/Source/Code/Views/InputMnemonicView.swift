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

import QGrid

struct InputMnemonicView {
    @ObservedObject private var viewModel = ViewModel()

    init(language: Mnemonic.Language, strength: Mnemonic.Strength) {
        viewModel.language = language
        viewModel.strength = strength
    }
}

// MARK: - View
extension InputMnemonicView: View {
    var body: some View {
        VStack {
            List(viewModel.inputWords) { inputMnemonicWord in
                InputMnemonicCell(input: inputMnemonicWord)
            }

            Button("Print words") {
                self.viewModel.debug()
            }
        }
    }
}

// MARK: - ViewModel
extension InputMnemonicView {
    final class ViewModel: ObservableObject {

        fileprivate var inputWords = [MnemonicInput]()

        fileprivate var language: Mnemonic.Language = .english
        fileprivate var strength: Mnemonic.Strength = .wordCountOf12 {
            didSet {
                inputWords = (0..<strength.wordCount).map { MnemonicInput(id: $0) }
            }
        }

        func debug() {
            print(inputWords)
        }

    }
}

// MARK: - MnemonicInput (CellViewModel)
final class MnemonicInput: ObservableObject, Swift.Identifiable {

    @Published var word: String = ""
    let id: Int
    init(id: Int) {
        self.id = id
    }
}

extension MnemonicInput: CustomDebugStringConvertible {
    var debugDescription: String {
        var debugString = ""
        #if DEBUG
        debugString = word
        #endif
        return debugString
    }
}

struct InputMnemonicCell {
    @State var input: MnemonicInput
}

extension InputMnemonicCell: View {
    var body: some View {
        VStack {
            TextField("\(input.id + 1)", text: $input.word)
            HintView(input: input)
        }
    }
}

import Combine
struct HintView: View {

    @ObservedObject var input: MnemonicInput

    var body: some View {
        Text("current: \(input.word)")
     }
}


// MARK: - Identifiable
extension Mnemonic.Strength: Swift.Identifiable {
    var displayableString: String {
        return "#\(wordCount)"
    }

    public var id: Int {
        guard let index = Mnemonic.Strength.allCases.enumerated().first(where: { $0.element.wordCount == self.wordCount })?.offset else {
            incorrectImplementationShouldAlwaysBeAble(to: "Find index of mnemonic strength")
        }
        return index
    }

    static var max: Mnemonic.Strength { Mnemonic.Strength.allCases.last! }
}

extension Mnemonic.Language: Swift.Identifiable {
    public var id: Int {
        guard let index = Mnemonic.Language.allCases.enumerated().first(where: { $0.element.rawValue == self.rawValue })?.offset else {
            incorrectImplementationShouldAlwaysBeAble(to: "Find index of mnemonic language")
        }
        return index
    }
}
