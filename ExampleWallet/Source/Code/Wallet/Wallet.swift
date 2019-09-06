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
import Combine
import RadixSDK

public final class Wallet: ObservableObject {

    public let objectWillChange = PassthroughSubject<Void, Never>()

    private let hdWallet: HDWallet
    private unowned let preferences: Preferences
    private let addressFormatter: (PublicKey) -> Address

    init(
        hdWallet: HDWallet,
        preferences: Preferences,
        addressFormatter: @escaping (PublicKey) -> Address
    ) {
        self.hdWallet = hdWallet
        self.preferences = preferences
        self.addressFormatter = addressFormatter
    }
}

public extension Wallet {
    typealias Index = HDSubAccountAtIndex.Index

    func account(at index: Index) -> Account {
        defer { persistIndex() }
        return accountFromHDAccount(hdWallet.account(at: index))

    }

    var accounts: [Account] {
        return hdWallet.hdAccounts.map { accountFromHDAccount($0) }.sorted(by: \.index)
    }

    @discardableResult
    func addNewAccount() -> Account {
        defer { persistIndex() }
        let newAccount = accountFromHDAccount(hdWallet.addNewAccount())
        return newAccount
    }
}

private extension Wallet {

    func persistIndex() {
        preferences.highestKnownHDAccountIndex = HDSubAccountAtIndex.Index(accounts.count - 1)
        objectWillChange.send()
    }

    func accountFromHDAccount(_ hdAccount: HDSubAccountAtIndex) -> Account {
        let address = addressFromHDAccount(hdAccount)
        return Account(accountAtIndex: hdAccount, address: address)
    }

    func addressFromHDAccount(_ hdAccount: HDSubAccountAtIndex) -> Address {
        return addressFormatter(hdAccount.publicKey)
    }
}

public struct Account: Swift.Identifiable {
    public let name: String
    public let address: Address
    private let account: HDSubAccountAtIndex
    init(accountAtIndex: HDSubAccountAtIndex, address: Address, name: String? = nil) {
        self.account = accountAtIndex
        self.address = address
        self.name = name ?? address.short
    }
}

public extension Account {
    typealias Index = HDSubAccountAtIndex.Index

    var publicKey: PublicKey {
        return account.publicKey
    }

    var index: Index { account.index }

    var id: Index { index }
}

