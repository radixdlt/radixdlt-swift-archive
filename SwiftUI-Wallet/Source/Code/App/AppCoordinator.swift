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

import Foundation
import SwiftUI

final class AppCoordinator {

    private let settingsStore: SettingsStore
    private let keychainStore: KeychainStore

    init(keychainStore: KeychainStore, settingsStore: SettingsStore) {
        self.keychainStore = keychainStore
        self.settingsStore = settingsStore
    }

    func initialScreen() -> some Screen {
        if !settingsStore.hasAgreedToTermsAndPolicy {
            return AnyScreen(WelcomeScreen().environmentObject(settingsStore))
        } else {
            //            return AnyScreen(GetStartedScreen())
            keychainStore.deleteValue(for: .mnemonic)
            keychainStore.deleteValue(for: .identity)

            return AnyScreen(IdentityCreationScreen().environmentObject(keychainStore))
        }

    }

}