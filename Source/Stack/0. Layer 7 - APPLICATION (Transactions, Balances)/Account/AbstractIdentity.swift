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
    
    public private(set) var accounts: NonEmptyArray<Account>
//    public private(set) var activeAccount: Account {
//        didSet {
//            accountSubject.onNext(activeAccount)
//        }
//    }
    private let accountSubject: BehaviorSubject<Account>
    
    public init(
        accounts: NonEmptyArray<Account>,
        selectInitialActiveAccount: AccountSelector = { $0.first }
    ) {
        self.accounts = accounts
        self.accountSubject = BehaviorSubject(value: selectInitialActiveAccount(accounts))
    }
}

public extension AbstractIdentity {
    /// HDWallet is NOT retained, this is just for convenience, you need to retain it yourself
    convenience init(hdWallet: HDWallet, highestKnownAccountIndex: Int = 0) {
        let accounts: [Account] = (0...highestKnownAccountIndex)
            .map { HDSubAccountAtIndex.Index($0) }
            .map { hdWallet.account(at: $0) }
            .map { Account.privateKeyPresent($0.keyPair) }

        self.init(accounts: NonEmptyArray.init(elements: accounts))
    }
}

public extension AbstractIdentity {

    var snapshotActiveAccount: Account {
        do {
            return try accountSubject.value()
        } catch {
            incorrectImplementation("Should always have an acctive account")
        }
    }
    
    @discardableResult
    func selectAccount(_ selector: AccountSelector) -> Account {
        let newActiveAccount = selector(accounts)
        accountSubject.onNext(newActiveAccount)
        return newActiveAccount
    }
    
    var activeAccountObservable: Observable<Account> {
        return accountSubject.asObservable()
    }

    func addAccount(_ newAccount: Account) {
        accounts.append(newAccount)
    }
}

// MARK: - CustomStringConvertible
public extension AbstractIdentity {
    var description: String {
        return """
        Accounts: #\(accounts.count)
        """
    }
}
