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
import QGrid

struct ConfirmMnemonicScreen {
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var viewModel = ViewModel()

    private let isPresentingBackUpFlow: Binding<Bool>

    init(mnemonicToBackUp: Mnemonic, isPresentingBackUpFlow: Binding<Bool>) {
        self.isPresentingBackUpFlow = isPresentingBackUpFlow
        viewModel.setMnemonic(mnemonicToBackUp)
    }
}

// MARK: - View
extension ConfirmMnemonicScreen: View {
    var body: some View {
        VStack {
            instructionsLabel
            selectedWordsList
            LabelledDivider(Text("available"))
            availableWordsList
            restartButton
            confirmButton
        }
        .padding([.leading, .trailing], 20)
        .onAppear { self.viewModel.unselectAll() }
        .navigationBarTitle("Confirm order")
    }
}

// MARK: Components
private extension ConfirmMnemonicScreen {

    var instructionsLabel: some View {
        Text("Tap on the words in the correct order")
            .font(.roboto(size: 18))
    }

    var selectedWordsList: some View {
        Grid(viewModel.selectedWords) { word in
            self.viewModel.removeFromSelected(word: word)
        }
    }

    var availableWordsList: some View {
        Grid.init(viewModel.availableWords) { word in
            self.viewModel.addToSelected(word: word)
        }
    }

    var restartButton: some View {
        Button("Restart") {
            self.viewModel.unselectAll()
        }.buttonStyleSapphire()
    }

    var confirmButton: some View {
        Button("Confirm") {
            self.appState.update().userDid.confirmBackUpOfMnemonic()
            self.isPresentingBackUpFlow.wrappedValue = false
        }
        .buttonStyleEmerald(enabled: self.viewModel.hasOrderedMnemonicWordsCorrectly)
        .enabled(self.viewModel.hasOrderedMnemonicWordsCorrectly)
    }
}

// MARK: - ViewModel
private extension ConfirmMnemonicScreen {
    final class ViewModel: ObservableObject {
        let objectWillChange = PassthroughSubject<Void, Never>()
        fileprivate var selectedWords = [MnemonicWord]()
        fileprivate var availableWords = [MnemonicWord]()

        private var correctOrderOfWords = [MnemonicWord]()
        private var shuffledOrderOfWords = [MnemonicWord]()
    }
}

private extension ConfirmMnemonicScreen.ViewModel {

    func setMnemonic(_ mnemonicToBackUp: Mnemonic) {

        let mnemonicWords = mnemonicToBackUp.words.map { $0.value }

        self.correctOrderOfWords = mnemonicWords.enumerated().map {
            MnemonicWord(id: $0.offset, word: $0.element)
        }

        shuffledOrderOfWords = correctOrderOfWords.shuffled()

        #if DEBUG
        shuffledOrderOfWords = correctOrderOfWords
        #endif

        unselectAll()
    }

    func addToSelected(word: MnemonicWord) {
        availableWords.removeAll(where: { $0.id == word.id })
        selectedWords.append(word)
        objectWillChange.send()
    }

    func removeFromSelected(word: MnemonicWord) {
        selectedWords.removeAll(where: { $0.id == word.id })
        availableWords.append(word)
        objectWillChange.send()
    }

    func unselectAll() {
        selectedWords = []
        availableWords = shuffledOrderOfWords
        objectWillChange.send()
    }

    var hasOrderedMnemonicWordsCorrectly: Bool {
        selectedWords == correctOrderOfWords
    }
}

// MARK: Grid
typealias Grid = QGrid
extension QGrid where Data.Element == MnemonicWord, Content == Button<Text> {
    init(_ data: Data, columns: Int = 3, onSelection: @escaping (Data.Element) -> Void) {
        self.init(data, columns: columns, columnsInLandscape: 5, vSpacing: 4, hSpacing: 4, vPadding: 4, hPadding: 4) { wordAtRow in
            Button("\(wordAtRow.word) (\(wordAtRow.id + 1))") {
                onSelection(wordAtRow)
            }
        }
    }
}
