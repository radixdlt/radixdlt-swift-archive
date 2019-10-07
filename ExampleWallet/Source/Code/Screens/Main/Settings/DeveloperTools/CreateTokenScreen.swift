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
import Combine

import RadixSDK

import KingfisherSwiftUI

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {
    
    var loadingText: String = "Loading..."
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                
                VStack {
                    Text(self.loadingText)
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isShowing ? 1 : 0)
                
            }
        }
    }
    
}

struct CreateTokenScreen {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var viewModel: ViewModel
}

// MARK: - View
extension CreateTokenScreen: View {
    var body: some View {
        NavigationView {
            LoadingView(isShowing: self.$viewModel.isLoading) {
                VStack {
                    self.inputList
                    self.createTokenButton
                }
            }
            .navigationBarTitle("Create a token")
        }.alert(isPresented: self.$viewModel.isPresentingErrorDialog) {
            self.invalidInputAlert
        }
    }
}

// MARK: - Subviews
private extension CreateTokenScreen {
    
    var inputList: some View {
        List {
            Section(header: Text("Basic")) {
                TextField("Symbol", text: $viewModel.input.symbol)
                TextField("Name", text: $viewModel.input.name)
                TextField("Description", text: $viewModel.input.description)
                TextField("Granularity", text: $viewModel.input.granularity)
            }
            
            Section(header: Text("Icon (optional)")) {
                TextField("Icon url (optional)", text: $viewModel.input.imageUrl)
                
                HStack {
                    Text("Preview of icon:")
                    
                    KFImage(viewModel.iconUrl)
                        .resizable()
                        .frame(width: 32, height: 32, alignment: .center)
                }
            }
            
            Section(header: Text("Supply")) {
                Picker("Supply type", selection: $viewModel.input.supplyType) {
                    ForEach(SupplyType.allCases) {
                        Text($0.displayedString).tag($0)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                
                Picker("Denomination", selection: $viewModel.input.denomination) {
                    ForEach(Denomination.allCases) {
                        Text($0.name).tag($0)
                    }
                }
                
                TextField(self.viewModel.supplyHint, text: $viewModel.input.supply)
                
                Text("Supply: \(self.viewModel.supplyFormatted)")
                
                if self.viewModel.input.supplyType == .mutable {
                    tokenPermissionsView
                }
            }
        }
    }
    
    var createTokenButton: some View {
        Button("Create") {
            self.viewModel.tryCreateToken {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .buttonStyleEmerald()
    }
    
    var invalidInputAlert: Alert {
        Alert(
            title: Text("Error"),
            message: Text(viewModel.createTokenError!.description)
        )
    }
    
    var tokenPermissionsView: some View {
        VStack {
            Toggle(isOn: $viewModel.input.anyoneHasPermissionToBurn) {
                Text("Anyone can burn")
            }
            
            Toggle(isOn: $viewModel.input.anyoneHasPermissionToMint) {
                Text("Anyone can mint")
            }
        }
    }
}

// MARK: ViewModel
extension CreateTokenScreen {
    final class ViewModel: ObservableObject {
        
        @Published fileprivate var input = Input()
        private unowned let radix: Radix
        private var cancellables = Set<AnyCancellable>()
        
        @Published fileprivate var isPresentingErrorDialog = false
        
        @Published fileprivate var isLoading = false
        
        @Published fileprivate var createTokenError: CreateTokenScreen.ViewModel.Error? {
            willSet {
                isPresentingErrorDialog = newValue != nil
            }
        }
        
        init(radix: Radix) {
            self.radix = radix
        }
    }
}


// MARK: ViewModel + Input
import RadixSDK
extension CreateTokenScreen.ViewModel {
    final class Input: ObservableObject {
        
        @Published fileprivate var name: String = ""
        @Published fileprivate var symbol: String = ""
        @Published fileprivate var description: String = loremIpsum(.firstFiveWords)
        @Published fileprivate var imageUrl: String = "" // "https://img.icons8.com/color/64/000000/swift.png"
        @Published fileprivate var granularity: String = "\(Granularity.default.magnitude)"
        
        @Published fileprivate var supplyType: SupplyType = .mutable
        @Published fileprivate var supply: String = "123"
        
        @Published fileprivate var denomination: Denomination = .whole
        
        @Published fileprivate var anyoneHasPermissionToBurn = false
        @Published fileprivate var anyoneHasPermissionToMint = false
        
        init() {
            let randomEnglishWord = Mnemonic.WordList.english.randomElement()!.value
            self.symbol = randomEnglishWord.uppercased()
            self.name = randomEnglishWord
        }
    }
}


// MARK: ViewModel + Error
extension CreateTokenScreen.ViewModel {
    enum Error: Swift.Error, CustomStringConvertible {
        indirect case inputError(InputError)
        
        enum InputError: Swift.Error, CustomStringConvertible {
            case name(Name.Error)
            case symbol(Symbol.Error)
            case description(Description.Error)
            case granularity(AmountError)
            case supply(SupplyFromInputError)
            case iconUrlStringNotAUrl
        }
        
        case networkError(Swift.Error)
    }
}

extension CreateTokenScreen.ViewModel.Error {
    enum SupplyFromInputError: Swift.Error, CustomStringConvertible {
        case supplyError(Supply.Error)
        case positiveAmountError(PositiveAmount.Error)
        case nonNegativeAmountError(NonNegativeAmount.Error)
    }
}

extension CreateTokenScreen.ViewModel.Error.SupplyFromInputError {
    public var description: String {
        switch self {
        case .supplyError(let error): return String(describing: error)
        case .positiveAmountError(let error): return String(describing: error)
        case .nonNegativeAmountError(let error): return String(describing: error)
        }
    }
}

extension CreateTokenScreen.ViewModel.Error {
    public var description: String {
        switch self {
        case .inputError(let inputError):
            return String(describing: inputError)
        case .networkError(let networkError):
            return "Network error: \(networkError)"
        }
    }
}

extension CreateTokenScreen.ViewModel.Error.InputError {
    public var description: String {
        let reason: String
        let field: String
        switch self {
        case .description(let error):
            field = "description"
            reason = String(describing: error)
        
        case .name(let error):
            field = "name"
            reason = String(describing: error)
            
        case .symbol(let error):
            field = "symbol"
            reason = String(describing: error)
            
        case .granularity(let error):
            field = "granularity"
            reason = String(describing: error)
            
        case .supply(let error):
            field = "supply"
            reason = String(describing: error)
            
        case .iconUrlStringNotAUrl:
            field = "iconUrl"
            reason = "Invalid url"
        }
        
        return "Invalid field: '\(field)', error: '\(reason)'"
    }
}

internal extension CreateTokenScreen.ViewModel {
    var supplyHint: String { input.supplyType.hint }
    
    var supplyFormatted: String {
        do {
            let nonNegativeAmount: NonNegativeAmount = try makeSupplyAmount(
                magnitudeString: input.supply,
                denomination: input.denomination
            )
            
            return nonNegativeAmount.displayUsingHighestPossibleNamedDenominator()
        } catch {
            return input.supply
        }
    }
    
    var canCreate: Bool {
        do {
            _ = try makeAction()
            return true
        } catch {
            return false
        }
    }
    
    func tryCreateToken(dismiss: @escaping () -> Void) {
        do {
            let token = try makeAction()
            isLoading = true
            radix.debug.createToken(token).sink(
                receiveCompletion: { completion in
                    self.isLoading = false
                    switch completion {
                    case .failure(let error):
                        print("⚠️ Token creation failed, error: \(error)")
                        self.createTokenError = .networkError(error)
                    case .finished:
                        print("✅ Successfully created token: '\(token.symbol)'")
                        dismiss()
                    }
                },
                receiveValue: { print("⚠️ Token creation update: \($0)") }
            ).store(in: &cancellables)
            
            createTokenError = nil
        } catch let createTokenError as CreateTokenScreen.ViewModel.Error {
            self.createTokenError = createTokenError
        } catch {
            incorrectImplementation("unexpected error type: \(error)")
        }
    }
 
}


// MARK: ViewModel - Input -> Models
private extension CreateTokenScreen.ViewModel {
    
    func makeSupplyAmount(magnitudeString: String, denomination: Denomination) throws -> NonNegativeAmount {
        return try NonNegativeAmount(string: magnitudeString, denomination: denomination)
    }
    
    func makeSupply(nonNegativeAmount: NonNegativeAmount, type: SupplyType) throws -> CreateTokenAction.InitialSupply.SupplyTypeDefinition {
        do {
            switch type {
            case .fixed:
                let positiveSupply = try PositiveSupply(unrelated: nonNegativeAmount)
                return .fixed(to: positiveSupply)
            case .mutable:
                let supply = try Supply(unrelated: nonNegativeAmount)
                return .mutable(initial: supply)
            }
        } catch let error as Supply.Error {
            throw Error.inputError(.supply(.supplyError(error)))
        } catch let positiveAmountError as PositiveAmount.Error {
            throw Error.inputError(.supply(.positiveAmountError(positiveAmountError)))
        } catch let nonNegativeAmountError as NonNegativeAmount.Error {
            throw Error.inputError(.supply(.nonNegativeAmountError(nonNegativeAmountError)))
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    
    func makeAction() throws -> CreateTokenAction {
        
        let supplyAmount = try makeSupplyAmount(magnitudeString: input.supply, denomination: input.denomination)
        
        return try CreateTokenAction(
            creator: myAddress,
            name: try name(),
            symbol: try symbol(),
            description: try description(),
            supply: try makeSupply(nonNegativeAmount: supplyAmount, type: input.supplyType),
            iconUrl: iconUrl,
            granularity: try granularity(),
            permissions: tokenPermissions
        )
    }
    
    var tokenPermissions: TokenPermissions? {
        switch input.supplyType {
        case .fixed: return nil
        case .mutable:
            let mintPermissions: TokenPermission = input.anyoneHasPermissionToMint ? .all : .tokenOwnerOnly
            let burnPermissions: TokenPermission = input.anyoneHasPermissionToBurn ? .all : .tokenOwnerOnly
            return [
                .mint: mintPermissions,
                .burn: burnPermissions
                
            ]
        }
    }
    
    func name() throws -> Name {
        do {
            return try Name(unvalidated: input.name)
        } catch let error as Name.Error {
            throw Error.inputError(.name(error))
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    
    func symbol() throws -> Symbol {
        do {
            return try Symbol(unvalidated: input.symbol)
        } catch let error as Symbol.Error {
            throw Error.inputError(.symbol(error))
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    
    func description() throws -> Description {
        do {
            return try Description(unvalidated: input.description)
        } catch let error as Description.Error {
            throw Error.inputError(.description(error))
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    
    func granularity() throws -> Granularity {
        do {
            return try Granularity(unvalidated: input.granularity)
        } catch let error as AmountError {
            throw Error.inputError(.granularity(error))
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    
    var myAddress: Address {
        radix.myActiveAddress
    }
    
    var iconUrl: URL? { URL(string: input.imageUrl) }
}

extension SupplyType: CaseIterable, Identifiable {
    public static var allCases: [SupplyType] { [.fixed, .mutable] }
    public var id: Int { rawValue }
    
    var displayedString: String {
        switch self {
        // TODO: localize!
        case .mutable: return "Mutable"
        case .fixed: return "Fixed"
        }
    }
    
    var hint: String {
        switch self {
        case .mutable: return "Supply (optional)"
        case .fixed: return "Supply (required > 0)"
        }
    }
}

extension Denomination: Identifiable {
    public var id: Int { exponent }
}
