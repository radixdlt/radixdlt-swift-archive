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
import RxSwift

public typealias Client = RadixApplicationClient

public final class Radix: ObservableObject {
    public static var shared: Radix?

    // MARK: Retained here only
    private let client: Client
    private let wallet: Wallet

    // MARK: Non Retained
//    private unowned let securePersistence: SecurePersistence

    // MARK: ObservableObject
    public let objectWillChange = PassthroughSubject<Void, Never>()

    // MARK: Mutable
    public private(set) var activeAccount: Account
    
    @Published internal private(set) var assets = [Asset]()

    var myActiveAddress: Address {
        activeAccount.address
    }

    // MARK: Private
    private var cancellables = Set<AnyCancellable>()
    
    #if DEBUG
    lazy var debug = Debug(client: client)
    #endif

    private let rxDisposeBag = DisposeBag()
    
    init(client: Client, wallet: Wallet) {
        self.client = client
        self.wallet = wallet

        self.activeAccount = wallet.accountFromSimpleAccount(client.snapshotActiveAccount)
        forward(function: Client.observeActiveAccount) { [unowned self] myNewActive in
            self.activeAccount = wallet.accountFromSimpleAccount(myNewActive)
        }

        forward(function: Client.observeMyBalances) { [unowned self] myTokenBalances in
            print("💰 my token balances updated: \(myTokenBalances)")
            self.assets = myTokenBalances.balancePerToken.map {
                Asset(tokenBalance: $0.value)
            }
        }
        
        wallet.objectWillChange.subscribe(objectWillChange).store(in: &cancellables)
        
        client.pull(address: myActiveAddress).disposed(by: rxDisposeBag)
        
        client.observeMyTokenDefinitions().subscribe(onNext: { print("✅ my token: \($0)") }).disposed(by: rxDisposeBag)
    }

}

#if DEBUG
extension Radix {
    final class Debug {
        private unowned let client: Client
        init(client: Client) {
            self.client = client
        }
    }
}

extension Radix.Debug {
    func createToken(_ action: CreateTokenAction) -> AnyPublisher<Never, Swift.Error> {
        client.create(token: action).toCompletable().asPublisher()
    }
}
#endif

// MARK: - Private
private extension Radix {

    func forward<O, NextElement>(
        function: (Client) -> () -> O,
        notify: Bool = true,
        onNext: @escaping (NextElement) -> Void
    ) where O: ObservableConvertibleType, O.Element == NextElement {

        forward(
            observable: function(client)(),
            notify: notify,
            onNext: onNext
        )

    }

    func forward<O, NextElement>(
         from keyPath: KeyPath<Client, O>,
         notify: Bool = true,
         onNext: @escaping (NextElement) -> Void
     ) where O: ObservableConvertibleType, O.Element == NextElement {

        forward(
            observable: client[keyPath: keyPath],
            notify: notify,
            onNext: onNext
        )

     }

    func forward<O, NextElement>(
        observable: O,
        notify: Bool = true,
        onNext: @escaping (NextElement) -> Void
    ) where O: ObservableConvertibleType, O.Element == NextElement {

        observable
            .publisherAssertNoFailure
            .sink { [unowned self] (nextElement: NextElement) in
                onNext(nextElement)
                if notify {
                    DispatchQueue.main.async {
                        self.objectWillChange.send()
                    }
                }
        }
        .store(in: &cancellables)

    }

    var identity: AbstractIdentity {
        client.identity
    }
}

// MARK: - Internal
extension Radix {
    var accounts: [Account] { wallet.accounts }
    
    func switchAccount(to selectedAccount: Account) {
        client.changeAccount(to: selectedAccount.toSimpleAccount())
    }

    func addNewAccount() {
        let newAccount = wallet.addNewAccount()
        client.addAccount(newAccount.toSimpleAccount())
        client.pull(address: newAccount.address).disposed(by: rxDisposeBag)
    }
}

// MARL: - State
internal extension Radix {
    var hasEverReceivedAnyTransactionToAnyAccount: Bool {
        // TODO read transactions
        return true
    }
}
