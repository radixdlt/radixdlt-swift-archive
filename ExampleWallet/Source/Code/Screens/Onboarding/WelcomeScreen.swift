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
    @EnvironmentObject private var appState: AppState

    @State private var isPresentingTermsWebView = false
    @State private var isPresentingPrivacyWebView = false

    @State private var hasAgreedToTermsAndConditions = false
    @State private var hasAgreedToPrivacyPolicy = false
}

// MARK: - View
extension WelcomeScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                RadixLogo.whiteText.frame(height: 50, alignment: .center)
                Spacer()
                welcomeLabel
                toggleTermsAndConditions
                togglePrivacyPolicy

                Button("Welcome.Button.Proceed") {
                    self.proceedToWalletCreation()
                }
                .enabled(canProceed) // state
                .buttonStyleEmerald(enabled: canProceed) // coloring
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
        Toggle(isOn: $hasAgreedToTermsAndConditions) {
            modalWebView(link: .terms, isPresented: $isPresentingTermsWebView)
        }
    }

    var togglePrivacyPolicy: some View {
        Toggle(isOn: $hasAgreedToPrivacyPolicy) {
            modalWebView(link: .privacy, isPresented: $isPresentingPrivacyWebView)
        }
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

private extension WelcomeScreen {

    func proceedToWalletCreation() {
        appState.update().userDid.acceptTermsOfUse()
    }

    var canProceed: Bool {
        hasAgreedToTermsAndConditions && hasAgreedToPrivacyPolicy
    }
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

    var screen: AnyView {
        switch self {
        case .terms: return AnyView(TermsAndConditionsScreen())
        case .privacy: return AnyView(PrivacyPolicyScreen())
        }
    }
}

// MARK: - Preview

//#if DEBUG
//struct WelcomeScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            WelcomeScreen()
//                .environmentObject(Preferences.alreadyAgreedToTermsAndPolicy)
//                .environment(\.locale, Locale(identifier: "en"))
//
//            WelcomeScreen()
//                .environmentObject(Preferences.default)
//                .environment(\.locale, Locale(identifier: "en"))
//
//            WelcomeScreen()
//                .environmentObject(Preferences.default)
//                .environment(\.locale, Locale(identifier: "sv"))
//        }
//    }
//}
//
//private extension Preferences {
//    static var alreadyAgreedToTermsAndPolicy: Preferences {
//        let preferences = Preferences.default
//        preferences.hasAgreedToTermsAndConditions = true
//        preferences.hasAgreedToPrivacyPolicy = true
//        return preferences
//    }
//}
//
//#endif
