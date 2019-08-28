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

struct WelcomeScreen {
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: - View
extension WelcomeScreen: Screen {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                RadixLogo.whiteText.frame(height: 50, alignment: .center)
                Spacer()
                welcomeLabel
                toggleTermsAndConditions
                togglePrivacyPolicy
                proceedButton
            }
            .padding(.allEdgesButTop, 32)
            .background(backgroundImage)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: Subviews
private extension WelcomeScreen {

    var welcomeLabel: some View {
        Text("Welcome.Text.Body")
            .font(.roboto(size: 60))
            .foregroundColor(Color.Radix.forest)
            .lineLimit(5)
            .padding(.leading, -30) // ugly fix for alignment
    }

    var backgroundImage: some View {
        Image("Images/Background/Welcome")
            .resizable()
            .edgesIgnoringSafeArea(.top)
            .scaledToFill()
    }

    var toggleTermsAndConditions: some View {
        Toggle(isOn: $viewModel.hasAgreedToTermsAndConditions) {
            modalWebView(link: .terms, isPresented: $viewModel.isPresentingTermsWebViewModal)
        }
    }

    var togglePrivacyPolicy: some View {
        Toggle(isOn: $viewModel.hasAgreedToPrivacyPolicy) {
            modalWebView(link: .privacy, isPresented: $viewModel.isPresentingPrivacyWebViewModal)
        }
    }

    var proceedButton: some View {
        Button("Welcome.Button.Proceed") {
            self.viewModel.proceedToWalletCreation()
        }
        .buttonStyleEmerald(enabled: viewModel.hasAgreedToTermsAndPolicy)
    }
}

// MARK: View Builder
private extension WelcomeScreen {
    func modalWebView(link: Link, isPresented: Binding<Bool>) -> some View {

        Button(
            action: { isPresented.wrappedValue = true },
            label: {
                Text(verbatim: link.hyperTextLocalized)
                    .font(.roboto(size: 18))
                    .underline(color: Color.Radix.forest)
                    .foregroundColor(Color.white)
            }
        )
        .sheet(isPresented: isPresented) { link.screen }

    }
}

// MARK: - ViewModel
typealias WelcomeViewModel = WelcomeScreen.ViewModel

extension WelcomeScreen {
    final class ViewModel: ObservableObject {

        private var cancellable: Cancellable?
        private let settingsStore: Preferences

        // Navigation
        private let termsAccepted: () -> Void

        @Published fileprivate var hasAgreedToTermsAndConditions = false
        @Published fileprivate var hasAgreedToPrivacyPolicy = false
        @Published fileprivate var isPresentingTermsWebViewModal = false
        @Published fileprivate var isPresentingPrivacyWebViewModal = false

        init(settingsStore: Preferences, termsHaveBeenAccepted: @escaping () -> Void) {
            self.settingsStore = settingsStore
            self.termsAccepted = termsHaveBeenAccepted

            cancellable = Publishers.CombineLatest(
                $hasAgreedToTermsAndConditions,
                $hasAgreedToPrivacyPolicy
            ).map { $0.0 && $0.1 }.sink {
                settingsStore.hasAgreedToTermsAndPolicy = $0
            }
        }
    }
}

extension WelcomeViewModel {
    func proceedToWalletCreation() {
        termsAccepted()
    }
}

private extension WelcomeViewModel {
    var hasAgreedToTermsAndPolicy: Bool { settingsStore.hasAgreedToTermsAndPolicy }
}

// MARK: - Links
private extension WelcomeScreen {
    enum Link {
        case terms
        case privacy
    }
}

private extension WelcomeScreen.Link {
    private var hyperTextLocalizedStringKey: LocalizedStringKeyTmp {
        switch self {
        case .terms: return "Welcome.Text.AcceptTerms&Conditions"
        case .privacy: return "Welcome.Text.AcceptPrivacyPolicy"
        }
    }

    var hyperTextLocalized: String {
        return hyperTextLocalizedStringKey.localized()
    }

    var screen: AnyScreen {
        switch self {
        case .terms: return AnyScreen(TermsAndConditionsScreen())
        case .privacy: return AnyScreen(PrivacyPolicyScreen())
        }
    }
}

// MARK: - Preview

#if DEBUG
struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeScreen()
                .environmentObject(Preferences.alreadyAgreedToTermsAndPolicy)
                .environment(\.locale, Locale(identifier: "en"))

            WelcomeScreen()
                .environmentObject(Preferences.default)
                .environment(\.locale, Locale(identifier: "en"))

            WelcomeScreen()
                .environmentObject(Preferences.default)
                .environment(\.locale, Locale(identifier: "sv"))
        }
    }
}

private extension Preferences {
    static var alreadyAgreedToTermsAndPolicy: Preferences {
        let settingsStore = Preferences.default
        settingsStore.hasAgreedToTermsAndPolicy = true
        return settingsStore
    }
}

#endif
