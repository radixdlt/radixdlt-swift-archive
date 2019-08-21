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

struct WelcomeScreen: Screen {

    @EnvironmentObject private var settingsStore: SettingsStore

    @State private var hasAgreedToTermsAndConditions = false

    @State private var hasAgreedToPrivacyPolicy = false

    @State private var showTermsWebViewModal = false
    @State private var showPrivacyWebViewModal = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("Icon/Logo/Radix")

                Spacer()

                Text("Welcome.Text.Body")
                    .font(.roboto(size: 60))
                    .lineLimit(5)
                    .padding(.leading, -30) // ugly fix for alignment

                Toggle(isOn: $hasAgreedToTermsAndConditions) {
                    modalWebView(link: .terms, isPresented: $showTermsWebViewModal)
                }

                Toggle(isOn: $hasAgreedToPrivacyPolicy) {
                    modalWebView(link: .privacy, isPresented: $showPrivacyWebViewModal)
                }

                NavigationLink(destination: GetStartedScreen()) {
                    Text("Welcome.Button.Proceed")
                        .buttonStyleEmerald(enabled: hasAgreedToTermsAndPolicy)
                }
                .enabled(hasAgreedToTermsAndPolicy)
            }
            .padding(32)
        }
        .edgesIgnoringSafeArea(.top)
    }
}

// MARK: Private
private extension WelcomeScreen {

    var hasAgreedToTermsAndPolicy: Bool {
        let hasAgreedToBoth = hasAgreedToTermsAndConditions && hasAgreedToPrivacyPolicy
        settingsStore.hasAgreedToTermsAndPolicy = hasAgreedToBoth
        return hasAgreedToBoth
    }

    func modalWebView(link: Link, isPresented: Binding<Bool>) -> some View {

        Button(
            action: { isPresented.wrappedValue = true },
            label: { Text(verbatim: link.hyperTextLocalized) }
        )
        .sheet(isPresented: isPresented) { link.screen }

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
                .environmentObject(SettingsStore.hasAgreedToTermsAndPolicy)
                .environment(\.locale, Locale(identifier: "en"))

            WelcomeScreen()
                .environmentObject(SettingsStore())
                .environment(\.locale, Locale(identifier: "en"))

            WelcomeScreen()
                .environmentObject(SettingsStore())
                .environment(\.locale, Locale(identifier: "sv"))
        }
    }
}

private extension SettingsStore {
    static var hasAgreedToTermsAndPolicy: SettingsStore {
        let settingsStore = SettingsStore()
        settingsStore.hasAgreedToTermsAndPolicy = true
        return settingsStore
    }
}

#endif
