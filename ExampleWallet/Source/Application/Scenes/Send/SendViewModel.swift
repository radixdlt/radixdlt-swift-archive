// 
// MIT License
//
// Copyright (c) 2019 Radix DLT (https://radixdlt.com)
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
import RxCocoa
import RadixSDK

final class SendViewModel {
    private let bag = DisposeBag()
    
    private weak var navigator: SendNavigator?
    private unowned let radixApplicationClient: DefaultRadixApplicationClient

    init(navigator: SendNavigator, radixApplicationClient: DefaultRadixApplicationClient) {
        self.navigator = navigator
        self.radixApplicationClient = radixApplicationClient
    }
}

extension SendViewModel: ViewModelType {

    struct Input {
        let fetchBalanceTrigger: Driver<Void>
        let recepientAddress: Driver<String>
        let amountToSend: Driver<String>
        let sendTrigger: Driver<Void>
    }

    struct Output {
        let isFetchingBalance: Driver<Bool>
        let isSendButtonEnabled: Driver<Bool>
        let myAddress: Driver<String>
        let myXrdBalance: Driver<String>
    }

    func transform(input: Input) -> Output {

        let fetchBalanceSubject = BehaviorSubject<Void>(value: ())

        let fetchTrigger = Driver.merge(fetchBalanceSubject.asDriverOnErrorReturnEmpty(), input.fetchBalanceTrigger)

        let activityIndicator = ActivityIndicator()
        let myAddress = radixApplicationClient.addressOfActiveAccount
        let xrdTokenDefinition = radixApplicationClient.nativeTokenDefinition
        let xrdRri = radixApplicationClient.nativeTokenIdentifier

//        let balanceAndNonce: Driver<BalanceResponse> = fetchTrigger.withLatestFrom(wallet) { _, w in w.address }
//            .flatMapLatest {
//                self.service
//                    .getBalance(for: $0)
//                    .trackActivity(activityIndicator)
//                    .do(onNext: {
//                        print("Got balance: \($0)")
//                    }, onError: {
//                        print("Failed to get balance, error \($0)")
//                    })
//                    .asDriverOnErrorReturnEmpty()
//        }
        
        let balanceOfXrd: Driver<TokenBalance> = fetchTrigger.flatMapLatest { [unowned self] in
            self.radixApplicationClient.myBalanceOfNativeTokensOrZero().asDriverOnErrorReturnEmpty()
        }

        let recipient = input.recepientAddress.map { try? Address(string: $0) }

        let amount = input.amountToSend.map { try? PositiveAmount(string: $0)  }


        let payment: Driver<TransferTokenAction?> = Driver.combineLatest(recipient, amount, balanceOfXrd) {
            guard let recipient = $0, let amount = $1, amount <= $2.amount else {
                return nil
            }
            return TransferTokenAction(
                from: myAddress,
                to: recipient, amount: amount,
                tokenResourceIdentifier: xrdRri
            )
        }


//        let receipt: Driver<TransactionReceipt> = input.sendTrigger
//            .withLatestFrom(Driver.combineLatest(payment.filterNil(), wallet, input.password, network.asDriverOnErrorReturnEmpty()) { (payment: $0, keystore: $1.keystore, encyptedBy: $2, network: $3) })
//            .flatMapLatest {
//                print("Trying to pay: \($0.payment)")
//                return self.service.sendTransaction(for: $0.payment, keystore: $0.keystore, password: $0.encyptedBy, network: $0.network)
//                    .do(onNext: {
//                        print("Sent tx id: \($0.transactionIdentifier)")
//                    }, onError: {
//                        print("Failed to send transaction, error: \($0)")
//                    })
//                    .flatMapLatest {
//                        self.service.hasNetworkReachedConsensusYetForTransactionWith(id: $0.transactionIdentifier)
//                    } .asDriverOnErrorReturnEmpty()
//        }
//
        return Output(
            isFetchingBalance: activityIndicator.asDriver(),
            isSendButtonEnabled: payment.map { $0 != nil },
            myAddress: Driver.just(myAddress).map { $0.stringValue },
            myXrdBalance: balanceOfXrd.map { "\($0.amount) XRD" }
        )
    }
}
