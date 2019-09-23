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

struct CreateTokenScreen {
    @EnvironmentObject var radix: Radix
    @ObservedObject private var viewModel = ViewModel()
}

extension CreateTokenScreen {
    final class ViewModel: ObservableObject {

        @Published fileprivate var input = Input()
        
        final class Input: ObservableObject {
            @Published fileprivate var name: String = ""
            @Published fileprivate var symbol: String = ""
            @Published fileprivate var description: String = ""
            @Published fileprivate var imageUrl: String = ""
            @Published fileprivate var granularity: String = ""
            
            @Published fileprivate var supplyType: SupplyType = .mutable
        }
    }
}

extension SupplyType: CaseIterable, Swift.Identifiable {
    public static var allCases: [SupplyType] { [.fixed, .mutable] }
    public var id: Int { rawValue }
    var displayedString: String {
        switch self {
            // TODO: localize!
        case .mutable: return "Mutable"
        case .fixed: return "Fixed"
        }
    }
}

extension CreateTokenScreen: View {
    var body: some View {
        NavigationView {
            List {
                
                Section(header: Text("Basic")) {
                    TextField("Symbol", text: $viewModel.input.symbol)
                    TextField("Name", text: $viewModel.input.name)
                    TextField("Description", text: $viewModel.input.description)
                    TextField("Image url", text: $viewModel.input.imageUrl)
                    TextField("Granularity", text: $viewModel.input.granularity)
                }
                
                Section(header: Text("Supply")) {
                    Picker("Supply type", selection: $viewModel.input.supplyType) {
                        ForEach(SupplyType.allCases) {
                            Text($0.displayedString).tag($0)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if self.viewModel.input.supplyType == .mutable {
                        Text("You have selected Mutable")
                    } else if self.viewModel.input.supplyType == .fixed {
                        Text("You have selected Fixed")
                    } else {
                        Text("This is impossible.")
                    }
                }
                
            }.navigationBarTitle("Create a token")
        }
    }
}

//import SwiftUI
import Combine

struct DecimalTextField: View {

    @ObservedObject private var viewModel = DecimalTextFieldViewModel()

    private let label: String
    private var subCancellable: AnyCancellable!
    
    init(_ label: String, text: AnySubscriber<String, Never>) {
        self.label = label
        subCancellable = viewModel.$text.sink { newText in
            _ = text.receive(newText)
        }
    }

    var body: some View {
        TextField(self.label, text: $viewModel.text)
    }
}

private extension DecimalTextField {
    private class DecimalTextFieldViewModel: ObservableObject {
           @Published var text = ""
           private var subCancellable: AnyCancellable!
           private var validCharSet = CharacterSet(charactersIn: "1234567890.")

           init() {
               subCancellable = $text.sink { val in
                   //check if the new string contains any invalid characters
                   if val.rangeOfCharacter(from: self.validCharSet.inverted) != nil {
                       //clean the string (do this on the main thread to avoid overlapping with the current ContentView update cycle)
                       DispatchQueue.main.async {
                           self.text = String(self.text.unicodeScalars.filter {
                               self.validCharSet.contains($0)
                           })
                       }
                   }
               }
           }

           deinit {
               subCancellable.cancel()
           }
       }
}
