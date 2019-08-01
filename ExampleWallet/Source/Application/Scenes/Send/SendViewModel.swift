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
    private unowned let radixApplicationClient: RadixApplicationClient

    init(navigator: SendNavigator, radixApplicationClient: RadixApplicationClient) {
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
        let statusOfSubmittedAtom: Driver<String>
    }

    func transform(input: Input) -> Output {

        let fetchBalanceSubject = BehaviorSubject<Void>(value: ())

        let fetchTrigger = Driver<Void>.merge(fetchBalanceSubject.asDriverOnErrorReturnEmpty(), input.fetchBalanceTrigger)

        let activityIndicator = ActivityIndicator()
        let myAddress = radixApplicationClient.addressOfActiveAccount
        let xrdTokenDefinition = radixApplicationClient.nativeTokenDefinition
        let xrdRri = radixApplicationClient.nativeTokenIdentifier
        
        let balanceOfXrd: Driver<TokenBalance> = fetchTrigger.flatMapLatest { [unowned self] _ in
            self.radixApplicationClient.observeMyBalanceOfNativeTokensOrZero().asDriverOnErrorReturnEmpty()
        }

        let recipient = input.recepientAddress.map { try? Address(string: $0) }

        let amount = input.amountToSend.map { try? PositiveAmount(string: $0)  }

        let transfer: Driver<TransferTokenAction?> = Driver.combineLatest(recipient, amount, balanceOfXrd) {
            guard let recipient = $0, let amount = $1, amount <= $2.amount else {
                return nil
            }
            return TransferTokenAction(
                from: myAddress,
                to: recipient, amount: amount,
                tokenResourceIdentifier: xrdRri
            )
        }
        
        let submissionUpdate: Observable<SubmitAtomAction> = input.sendTrigger.withLatestFrom(transfer.filterNil()) { [unowned self] _, transfer -> ResultOfUserAction in
            return self.radixApplicationClient.transfer(tokens: transfer)
        }.asObservable().flatMap {
            $0.toObservable()
        }.do(afterCompleted: { fetchBalanceSubject.onNext(()) })

        return Output(
            isFetchingBalance: activityIndicator.asDriver(),
            isSendButtonEnabled: transfer.map { $0 != nil },
            myAddress: Driver.just(myAddress).map { $0.stringValue },
            myXrdBalance: balanceOfXrd.map { "\($0.amount) \(xrdTokenDefinition.name)" },
            statusOfSubmittedAtom: submissionUpdate.materialize().map {
                switch $0 {
                case .next(let update): return "update: \(update)"
                case .error(let error): return "error: \(error)"
                case .completed: return "Completed"
                }
            }.asDriverOnErrorReturnEmpty()
        )
    }
}
