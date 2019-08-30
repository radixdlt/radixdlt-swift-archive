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

struct SettingsScreen {

//    @Environment(\.presentationMode) var presentation

    // MARK: - Injected properties
    @EnvironmentObject private var appModel: AppModel
}

// MARK: - View
extension SettingsScreen: View {
    var body: some View {
        List {
            appVersion.map { appVersion in
                Text("App version: \(appVersion)")
            }

            NavigationLink(destination: ConnectedToNodesScreen()) {
                Text("Connected nodes")
            }

            Button("Delete wallet") {
                self.appModel.deleteWallet()
            }.buttonStyleRuby()

            Button("Clear settings") {
                self.appModel.clearPreferences()
            }.buttonStyleRuby()
        }
    }
}

extension SettingsScreen {

//    func deleteWallet() {
//        appModel.securePersistence.deleteAll()
//        appModel.isWalletSetup = false
////        presentation.wrappedValue.dismiss()
//    }
//
//    func clearPreferences() {
//        appModel.preferences.deleteAll()
//        appModel.hasAcceptedTermsAndConditions_and_privacyPolicy = false
//    }

    var appVersion: String? {
        guard
             let info = Bundle.main.infoDictionary,
             let version = info["CFBundleShortVersionString"] as? String,
             let build = info["CFBundleVersion"] as? String
            else { return nil }
         return "\(version) (\(build))"
    }
}

