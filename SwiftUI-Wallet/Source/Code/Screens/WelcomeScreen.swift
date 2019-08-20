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

    @EnvironmentObject var userData: UserData

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("Icon/Logo/Radix")

                Spacer()

                Text("Welcome.Text.Body")
                    .font(.roboto(size: 60))
                    .lineLimit(5)
                    .padding(.leading, -30) // ugly fix for alignment

                Toggle(isOn: $userData.hasAgreedToTermsAndConditions) {
                    Text("Welcome.Text.AcceptTerms&Conditions")
                }.toggleStyle(DefaultToggleStyle())

                Toggle(isOn: $userData.hasAgreedToPrivacyPolicy) {
                    Text("Welcome.Text.AcceptPrivacyPolicy")
                }.toggleStyle(DefaultToggleStyle())

                NavigationLink(destination: GetStartedScreen(), label: {
                    Text("Welcome.Button.Proceed")
                        .buttonStyleEmerald(enabled: self.canProceed)

                }).enabled(self.canProceed())
            }
            .padding(32)
        }
        .edgesIgnoringSafeArea(.top)
    }

    var canProceed: () -> Bool {
        return { self.userData.hasAgreedToTermsAndConditions && self.userData.hasAgreedToPrivacyPolicy }
    }
}

#if DEBUG
struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeScreen()
                .environmentObject(UserData.hasAgreed)
                .environment(\.locale, Locale(identifier: "en"))

            WelcomeScreen()
                .environmentObject(UserData())
                .environment(\.locale, Locale(identifier: "en"))

            WelcomeScreen()
                .environmentObject(UserData())
                .environment(\.locale, Locale(identifier: "sv"))
        }
    }
}

private extension UserData {
    static var hasAgreed: UserData {
        let userData = UserData()
        userData.hasAgreedToPrivacyPolicy = true
        userData.hasAgreedToTermsAndConditions = true
        return userData
    }
}

#endif
