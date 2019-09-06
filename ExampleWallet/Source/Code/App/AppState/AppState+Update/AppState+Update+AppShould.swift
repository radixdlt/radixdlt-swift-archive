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

public extension AppState.Update {
    final class AppShould {

        private unowned let preferences: Preferences
        private unowned let securePersistence: SecurePersistence

        init(
            preferences: Preferences,
            securePersistence: SecurePersistence
        ) {
            self.preferences = preferences
            self.securePersistence = securePersistence
        }
    }
}

// MARK: - PUBLIC
public extension AppState.Update.AppShould {
    func connectToRadix() -> Radix {
        if let radix = Radix.shared {
            return radix
        }

        guard let seedFromMnemonic = securePersistence.seedFromMnemonic else {
            incorrectImplementation("Should have seed saved")
        }

        let hdWallet = HDWallet(
            seedFromMnemonic: seedFromMnemonic,
            highestKnownAccountIndex: preferences.highestKnownHDAccountIndex
        )

        let identity = AbstractIdentity(hdWallet: hdWallet)

        let radixUniverseBootstrap: BootstrapConfig = UniverseBootstrap.localhostSingleNode

        let client = RadixApplicationClient(
            bootstrapConfig: radixUniverseBootstrap,
            identity: identity
        )

        let magic = radixUniverseBootstrap.config.magic

        let wallet = Wallet(
            hdWallet: hdWallet,
            preferences: preferences
        ) { Address(magic: magic, publicKey: $0) }

        let radix = Radix(client: client, wallet: wallet)
        Radix.shared = radix
        return radix
    }
}
