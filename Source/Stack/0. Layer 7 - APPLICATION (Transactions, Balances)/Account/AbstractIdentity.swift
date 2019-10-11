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
import BitcoinKit

public final class AbstractIdentity: CustomStringConvertible {
    public typealias AccountSelector = (NonEmptyArray<Account>) -> Account
    
    public private(set) var accounts: NonEmptyArray<Account>
    private let accountSubject: CurrentValueSubjectNoFail<Account>
    
    public init(
        accounts: NonEmptyArray<Account>,
        selectInitialActiveAccount: AccountSelector = { $0.first }
    ) {
        self.accounts = accounts
        self.accountSubject = CurrentValueSubjectNoFail(selectInitialActiveAccount(accounts))
    }
}

public extension AbstractIdentity {
    /// HDWallet is NOT retained, this is just for convenience, you need to retain it yourself
    convenience init(hdWallet: HDWallet) {
        self.init(accounts: NonEmptyArray(elements: hdWallet.accounts))
    }
}

public extension AbstractIdentity {

    var snapshotActiveAccount: Account {
        accountSubject.value
    }
    
    @discardableResult
    func selectAccount(_ selector: AccountSelector) -> Account {
        let newActiveAccount = selector(accounts)
        accountSubject.onNext(newActiveAccount)
        return newActiveAccount
    }

    func changeAccount(to selectedAccount: Account) {
        guard accounts.contains(selectedAccount) else {
            incorrectImplementation("AbstractIdentity does not contain account: \(selectedAccount)")
        }
        accountSubject.onNext(selectedAccount)
    }
    
    var activeAccountObservable: CombineObservable<Account> {
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
