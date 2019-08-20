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

struct WelcomeScene: View {

    @State var hasAgreedToTermsAndConditions = false
    @State var hasAgreedToPrivacyPolicy = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("Icon/Logo/Radix")

                Spacer()

                Text("WelcomeScene.Body.SendMessagesAndTokens")
                    .font(.roboto(size: 60))
                    .lineLimit(5)
                    .padding(.leading, -30) // ugly fix for alignment

                Toggle(isOn: $hasAgreedToTermsAndConditions) {
                    Text("I agree to the Terms and Conditions")
                }.toggleStyle(DefaultToggleStyle())

                Toggle(isOn: $hasAgreedToPrivacyPolicy) {
                    Text("I agree to the Privacy Policy")
                }.toggleStyle(DefaultToggleStyle())

                NavigationLink(destination: GetStartedScene(), label: {
                    Text("Get started")
                        .buttonStyleEmerald(enabled: self.canProceed)

                }).enabled(self.canProceed())
            }
            .padding(32)
        }
        .edgesIgnoringSafeArea(.top)
    }

    var canProceed: () -> Bool {
        return { self.hasAgreedToTermsAndConditions && self.hasAgreedToPrivacyPolicy }
    }
}

#if DEBUG
struct WelcomeScene_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScene()
    }
}
#endif
