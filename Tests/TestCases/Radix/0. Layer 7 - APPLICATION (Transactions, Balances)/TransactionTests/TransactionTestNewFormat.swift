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
import XCTest
@testable import RadixSDK
import RxSwift

// An alternative way of writing unit tests.
class TransactionTestNewFormat: XCTestCase {
    
    func test_transaction_with_single_create_token_action_with_initial_supply() {
        given_identity_alice_and_a_radix_application_client { (aliceApp) in
            when_alice_observes_her_transactions_after_creating_token(withSupply: .mutable(initial: 123), given: aliceApp) { transactions in
                then_a_transaction_can_be_seen(amongst: transactions) { transaction in
                    switch transaction.actions.countedElementsZeroOneTwoAndMany {
                    // THEN one CreateTokenAction can be seen in the transaction
                    case .two(let first, let secondAndLast):
                        guard
                            let createTokenAction = first as? CreateTokenAction,
                            let mintTokenAction = secondAndLast as? MintTokensAction
                            else { return XCTFail("Expected first action to be `CreateTokenAction`, and second to be MintTokensAction.")  }
                        
                        XCTAssertEqual(createTokenAction.tokenSupplyType, .mutable)
                        XCTAssertEqual(mintTokenAction.amount, 123)
                    default: XCTFail("Expected exactly two actions")
                    }
                }
            }
        }
    }
    
    func test_transaction_with_single_create_token_action_without_initial_supply() {
 
        given_identity_alice_and_a_radix_application_client { (aliceApp) in
            when_alice_observes_her_transactions_after_creating_token(withSupply: .mutableZeroSupply, given: aliceApp) { transactions in
                then_a_transaction_can_be_seen(amongst: transactions) { transaction in
                    XCTAssertEqual(transaction.actions.count, 1)
                    guard let createTokenAction = transaction.actions.first as? CreateTokenAction else {
                        return XCTFail("Transaction is expected to contain exactly one `CreateTokenAction`, nothing else.")
                    }
                    XCTAssertEqual(createTokenAction.tokenSupplyType, .mutable)
                }
            }
        }
    }
}

// MARK: Private reusable helper methods
private extension TransactionTestNewFormat {
    func given_identity_alice_and_a_radix_application_client(
        _ fulfil: (RadixApplicationClient) -> Void
    ) {
        fulfil(RadixApplicationClient.localhostAliceSingleNodeApp)
    }
    
    func when_alice_observes_her_transactions_after_creating_token(
        withSupply initialSupply: CreateTokenAction.InitialSupply.SupplyTypeDefinition,
        given app: RadixApplicationClient,
        _ fulfil: (Observable<ExecutedTransaction>) -> Void
    ) {
        
        XCTAssertTrue(
            app.createToken(defineSupply: initialSupply)
                .result
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
       fulfil(app.observeTransactions(at: app.addressOfActiveAccount))
    }
    
    func then_a_transaction_can_be_seen(
        amongst transactionObservable: Observable<ExecutedTransaction>,
        _ fulfil: (ExecutedTransaction) -> Void
    ) {

        guard let transaction = transactionObservable.blockingTakeFirst(timeout: 1) else {
            return
        }
        
        fulfil(transaction)
    }
}
