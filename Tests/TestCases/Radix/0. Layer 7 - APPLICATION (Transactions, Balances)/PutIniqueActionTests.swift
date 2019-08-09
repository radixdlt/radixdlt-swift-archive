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

class PutUniqueIdActionTests: LocalhostNodeTest {
    
    private let disposeBag = DisposeBag()
    
    private var aliceIdentity: AbstractIdentity!
    private var bobAccount: Account!
    private var application: RadixApplicationClient!
    private var alice: Address!
    private var bob: Address!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        aliceIdentity = AbstractIdentity(alias: "Alice")
        bobAccount = Account()
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobAccount)
    }
    
    func testSendTransactionWithSingleUniqueId() {

        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        
        // WHEN: Alice sends a `Transaction` containing a `UniqueId` with the string `"foobar"`
        let transaction = Transaction {[
            PutUniqueIdAction(uniqueMaker: alice, string: "foobar")
        ]}
        
        XCTAssertTrue(
            application.send(transaction: transaction)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )

        guard let executedTransaction: ExecutedTransaction = application.observeTransactions(at: alice, containingActionOfAnyType: [PutUniqueIdAction.self]).blockingTakeFirst(timeout: 1) else { return }

        let putUniqueActions = executedTransaction.actions(ofType: PutUniqueIdAction.self)

        XCTAssertEqual(putUniqueActions.count, 1)
        let putUniqueAction = putUniqueActions[0]
        
        // THEN: AND we can read out the `UniqueId` string `"foobar"`
        XCTAssertEqual(putUniqueAction.string, "foobar")
    }
    
    func testSendTransactionWithTwoUniqueIds() {
        
        // GIVEN: identity Alice and a RadixApplicationClient connected to some Radix node
        
        // WHEN: Alice sends a `Transaction` containing two UniqueId with the string "foo" and "bar” respectively
        let transaction = Transaction {[
            PutUniqueIdAction(uniqueMaker: alice, string: "foo"),
            PutUniqueIdAction(uniqueMaker: alice, string: "bar")
        ]}
        
        XCTAssertTrue(
            application.send(transaction: transaction)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        guard let executedTransaction: ExecutedTransaction = application.observeTransactions(at: alice, containingActionOfAnyType: [PutUniqueIdAction.self]).blockingTakeFirst(timeout: 1) else { return }
        
        let putUniqueActions = executedTransaction.actions(ofType: PutUniqueIdAction.self)
        
        XCTAssertEqual(putUniqueActions.count, 2)
        
        // THEN: AND we can read out the UniqueId strings "foo" and "bar”.
        XCTAssertEqual(putUniqueActions[0].string, "foo")
        XCTAssertEqual(putUniqueActions[1].string, "bar")
    }
}
