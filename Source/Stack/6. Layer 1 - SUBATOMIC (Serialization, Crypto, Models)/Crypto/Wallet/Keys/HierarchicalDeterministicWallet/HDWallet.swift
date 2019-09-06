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
import BitcoinKit

/// Hierarchical Deterministic ("HD") Account derived from some HD Root Key
public final class HDSubAccountAtIndex {
    public typealias Index = UInt32
    public let index: Index
    public let keyPair: KeyPair
    public init(index: UInt32, keyPair: KeyPair) {
        self.index = index
        self.keyPair = keyPair
    }
}

public extension HDSubAccountAtIndex {
    var publicKey: PublicKey { keyPair.publicKey }
}

/// Hierarchical Deterministic ("HD")  Root Key wrapper
public final class HDWallet: CustomStringConvertible {
    private let hdWallet: BitcoinKit.HDWallet
    private var derivedAccounts = [HDSubAccountAtIndex.Index: HDSubAccountAtIndex]()

    public init(hdWallet: BitcoinKit.HDWallet, highestKnownAccountIndex: HDSubAccountAtIndex.Index = 0) {
        self.hdWallet = hdWallet
        deriveAccountsUpTo(index: highestKnownAccountIndex)
    }

    public convenience init(seedFromMnemonic hdWalletSeed: Data, highestKnownAccountIndex: HDSubAccountAtIndex.Index = 0) {
        let wallet = BitcoinKit.HDWallet(seed: hdWalletSeed, network: BitcoinKit.Network.testnetBTC)
        self.init(hdWallet: wallet, highestKnownAccountIndex: highestKnownAccountIndex)
    }
}

public extension HDWallet {

    /// Accesses or creates and account at the
    @discardableResult
    func account(at index: HDSubAccountAtIndex.Index) -> HDSubAccountAtIndex {
        if let existingAccount = derivedAccounts[index] {
            return existingAccount
        }
        let keyPair = KeyPair(private: privateKey(at: index))
        let account = HDSubAccountAtIndex(index: index, keyPair: keyPair)
        derivedAccounts[index] = account
        return account
    }

    func deriveAccountsUpTo(index maxIndex: HDSubAccountAtIndex.Index) {
        for index in HDSubAccountAtIndex.Index(0)...maxIndex {
            account(at: index)
        }
    }

    var hdAccounts: [HDSubAccountAtIndex] {
        derivedAccounts.map { $0.value }
    }

    var accounts: [Account] {
        hdAccounts.map { Account.privateKeyPresent($0.keyPair) }
    }

    @discardableResult
    func addNewAccount() -> HDSubAccountAtIndex {
        account(at: HDSubAccountAtIndex.Index(derivedAccounts.count))
    }
}

public extension HDWallet {
    var description: String {
        return "<omitted for security reasons>"
    }
}

#if DEBUG
extension HDWallet: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "#accounts: \(derivedAccounts.count)"
    }
}
#endif

// MARK: BitcoinKit
private extension HDWallet {
    func privateKey(at index: HDSubAccountAtIndex.Index) -> PrivateKey {
        do {
            let extendedPrivateKey: BitcoinKit.HDPrivateKey = try hdWallet.extendedPrivateKey(index: index)
            let privateKeyBitcoinKit: BitcoinKit.PrivateKey = extendedPrivateKey.privateKey()
            return try PrivateKey(data: privateKeyBitcoinKit.data)
        } catch {
            incorrectImplementation("Should be able to derive key, got error: \(error)")
        }
    }
}
//let accounts: [Account] = (0...highestKnownAccountIndex)
//         .map { HDSubAccountAtIndex.Index($0) }
//         .map { hdWallet.account(at: $0) }
//         .map { Account.privateKeyPresent($0.keyPair) }
