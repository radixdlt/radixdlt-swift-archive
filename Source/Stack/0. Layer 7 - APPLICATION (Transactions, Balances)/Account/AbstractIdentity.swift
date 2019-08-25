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
import RxSwift
import BitcoinKit

public final class AbstractIdentity: CustomStringConvertible {
    public typealias AccountSelector = (NonEmptyArray<Account>) -> Account
    
    public var alias: String?
    public private(set) var accounts: NonEmptyArray<Account>
    public private(set) var activeAccount: Account {
        didSet {
            accountSubject.onNext(activeAccount)
        }
    }
    private let accountSubject: BehaviorSubject<Account>
    
    public init(
        accounts: NonEmptyArray<Account>,
        alias: String? = nil,
        selectInitialActiveAccount: AccountSelector = { $0.first }
    ) {
        self.accounts = accounts
        self.alias = alias
        self.activeAccount = selectInitialActiveAccount(accounts)
        self.accountSubject = BehaviorSubject(value: activeAccount)
    }
}

public extension AbstractIdentity {
    static func new(
        alias: String? = nil,
        mnemonicGenerator: Mnemonic.Generator = .default,
        backedUpMneumonic: @escaping (Mnemonic) -> MnemonicBackedUpByUser
    ) -> Single<AbstractIdentity> {
        return newWithoutConfirmationOfBackup(alias: alias, mnemonicGenerator: mnemonicGenerator) {
            _ = backedUpMneumonic($0)
        }
    }

    static func newWithoutConfirmationOfBackup(
        alias: String? = nil,
        mnemonicGenerator: Mnemonic.Generator = .default,
        backedUpMneumonic: @escaping (Mnemonic) -> Void
    ) -> Single<AbstractIdentity> {

        return Single<AbstractIdentity>.create { single in

            do {
                let mnemonic = try mnemonicGenerator.generate()

                // async
                backedUpMneumonic(mnemonic)

                // TODO: replace BTC network with Radix one...
                let wallet = BitcoinKit.HDWallet(seed: mnemonic.seed, network: BitcoinKit.Network.testnetBTC)

                let privateKeyBicoinKit = try wallet.privateKey(index: 0)

                let privateKey = try PrivateKey(data: privateKeyBicoinKit.data)

                let account = Account(privateKey: privateKey)

                let identity = AbstractIdentity(accounts: [account], alias: alias)

                single(.success(identity))
            } catch {
                single(.error(error))
            }

            return Disposables.create()
        }
    }
}

internal extension AbstractIdentity {
    
    #if DEBUG
    static func newSkippingBackup(alias: String? = nil) -> Single<AbstractIdentity> {
        return new(alias: alias, backedUpMneumonic: { MnemonicBackedUpByUser(mnemonic: $0) })
    }
    
    convenience init(alias: String? = nil) {
        let identitySingle = AbstractIdentity.newSkippingBackup(alias: alias).toBlocking(timeout: 1)
        do {
            guard let identity = try identitySingle.first() else {
                incorrectImplementation("Should always be able to create identity")
            }
            self.init(accounts: identity.accounts, alias: alias)
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
    #endif
}

public extension AbstractIdentity {
    
    @discardableResult
    func selectAccount(_ selector: AccountSelector) -> Account {
        self.activeAccount = selector(accounts)
        return activeAccount
    }
    
    var activeAccountObservable: Observable<Account> {
        return accountSubject.asObservable()
    }
}

// MARK: - CustomStringConvertible
public extension AbstractIdentity {
    var description: String {
        return """
        Accounts: #\(accounts.count)\(alias.ifPresent { ",\nalias: \($0)" })
        """
    }
}
