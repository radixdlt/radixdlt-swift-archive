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
import RadixSDK

// MARK: AppState.Update.UserDid
public extension AppState.Update {
    final class UserDid {

        private unowned let preferences: Preferences
        private unowned let securePersistence: SecurePersistence
        private let triggerNavigation: () -> Void

        init(
            preferences: Preferences,
            securePersistence: SecurePersistence,
            triggerNavigation: @escaping () -> Void
        ) {
            self.preferences = preferences
            self.securePersistence = securePersistence
            self.triggerNavigation = triggerNavigation
        }
    }
}

// MARK: User Did Update
public extension AppState.Update.UserDid {

    /// "Terms of use" is short for "Terms & Conditions and Privacy Policy"
    func acceptTermsOfUse() {
        preferences.hasAgreedToTermsOfUse = true
        triggerNavigation()
    }

    func generate(mnemonic: Mnemonic) {
        securePersistence.mnemonic = mnemonic
        securePersistence.seedFromMnemonic = mnemonic.seed
        triggerNavigation()
    }

    func deleteWallet() {
        securePersistence.deleteAll()
        triggerNavigation()
    }

    func deletePreferences() {
        preferences.deleteAll()
    }

    func confirmBackUpOfMnemonic() {
        // Only store the seed of the mnemonic, not the mnemonic itself, after user has confirm she knows the mnemonic (and securely stored it somewhere).
        securePersistence.deleteValue(forKey: .mnemonic, notifyChange: false)
    }
}
