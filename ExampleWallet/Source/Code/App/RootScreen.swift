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

// MARK: - ROOT SCREEN
struct RootScreen {
    @EnvironmentObject private var appModel: AppModel
}

extension RootScreen: View {
    var body: some View {

        func root<V>(view: V) -> AnyView where V: View {
            return view.environmentObject(self.appModel).eraseToAny()
        }

        //        Group {
        //            if appModel.appState.hasSetupWallet {
        ////                MainScreen()
        //
        //            } else {
        //                Onboarding()
        //            }
        //        }

        return Text("<ROOT>").sheet(
            item: $appModel.appState.rootContent,
            content: { (newRootContent: RootContent) -> AnyView in
                print("RootScreen - newRootContent: \(newRootContent)")
                switch newRootContent {
                case .main: return root(view: MainScreen())
                case .welcome: return root(view: WelcomeScreen())
                case .getStarted: return root(view: GetStartedScreen())
                }
            }
        )
//            .onAppear { self.setInitialRootContent() }
    }

//    var initialView: RootContent {
//        guard appModel.appState.hasAcceptedTermsAndPrivacyPolicy else {
//            return .welcome
//        }
//
//        guard appModel.appState.hasSetupWallet else {
//            return .getStarted
//        }
//
//        return .main
//    }
//
//    func setInitialRootContent() {
//        appModel.appState.rootContent = initialView
//    }
}

//struct Onboarding {
//    @EnvironmentObject private var appModel: AppModel
//}
//
//extension Onboarding: View {
//    var body: some View {
//        Group {
//            if appModel.appState.hasAcceptedTermsAndPrivacyPolicy {
//                GetStartedScreen()
//            } else {
//                WelcomeScreen()
//            }
//        }
//    }
//}
