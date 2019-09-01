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
    @EnvironmentObject private var appState: AppState
}

// MARK: - View
extension SettingsScreen: View {
    var body: some View {
        List {
            appVersion.map { appVersion in
                Text("App version: \(appVersion)")
            }

            Button("Delete wallet") {
                self.deleteWallet()
            }.buttonStyleRuby()

            Button("Clear settings") {
                self.clearPreferences()
            }.buttonStyleRuby()
        }
    }
}

extension SettingsScreen {

    func deleteWallet() {
        appState.update().userDid.deleteWallet()
    }

    func clearPreferences() {
        appState.update().userDid.deletePreferences()
    }

    var appVersion: String? {
        guard
             let info = Bundle.main.infoDictionary,
             let version = info["CFBundleShortVersionString"] as? String,
             let build = info["CFBundleVersion"] as? String
            else { return nil }
         return "\(version) (\(build))"
    }
}

