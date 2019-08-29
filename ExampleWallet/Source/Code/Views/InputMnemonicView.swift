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
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: - View
extension InputMnemonicView: View {
    var body: some View {
        VStack {
            // seems like the `title` below isn't displayed??
            Picker("Displayed?", selection: $viewModel.mnemonicLengthSelectionIndex) {
                ForEach(viewModel.selectableMnemonicStrenths) { strength in
                    Text(strength.displayableString)
                }
            }.pickerStyle(SegmentedPickerStyle())

            QGrid(viewModel.cellViewModelsAccordingToSelectedStrength, columns: 2, vSpacing: 4, hSpacing: 4, vPadding: 4, hPadding: 4) { selectedCellViewModel in
                     InputMnemonicCell(cellViewModel: selectedCellViewModel)
            }
            .frame(width: nil, height: 500, alignment: .center)
        }
    }
}

// MARK: - ViewModel
typealias InputMnemonicViewModel = InputMnemonicView.ViewModel

extension InputMnemonicView {
    final class ViewModel: ObservableObject {
        fileprivate let allCellViewModels: [InputMnemonicWordCellViewModel]
        fileprivate let mnemonicRestored: (Mnemonic) -> Void

        @Published fileprivate var mnemonicLengthSelectionIndex = 0

        init(mnemonicRestored: @escaping (Mnemonic) -> Void) {
            self.mnemonicRestored = mnemonicRestored
            self.allCellViewModels = (0..<Mnemonic.Strength.max.wordCount).map { InputMnemonicWordCellViewModel(index: $0) }
        }
    }
}

private extension InputMnemonicViewModel {


    var selectedMnemonicStrength: Mnemonic.Strength {
        return selectableMnemonicStrenths[mnemonicLengthSelectionIndex]
    }

    var selectableMnemonicStrenths: [Mnemonic.Strength] {
        Mnemonic.Strength.allCases
    }

    var cellViewModelsAccordingToSelectedStrength: [InputMnemonicWordCellViewModel] {
        Array(
            allCellViewModels.prefix(selectedMnemonicStrength.wordCount)
        )
    }
}


// MARK: - InputMnemonicWordCellViewModel
final class InputMnemonicWordCellViewModel: Swift.Identifiable {
    var index: Int
    var word: String = ""
    init(index: Int) {
        self.index = index
    }
    var id: Int { index }
}

extension Mnemonic.Strength: Swift.Identifiable {
    var displayableString: String {
        return "#\(wordCount) words"
    }

    public var id: Int {
        guard let index = Mnemonic.Strength.allCases.enumerated().first(where: { $0.element.wordCount == self.wordCount })?.offset else {
            incorrectImplementationShouldAlwaysBeAble(to: "Find index of mnemonic strength")
        }
        return index
    }

    static var max: Mnemonic.Strength { Mnemonic.Strength.allCases.last! }
}

struct InputMnemonicCell {
    @State var cellViewModel: InputMnemonicWordCellViewModel
}
extension InputMnemonicCell: View {
    var body: some View {
        TextField("\(cellViewModel.index + 1)", text: $cellViewModel.word)
    }
}
