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

import XCTest
@testable import RadixSDK
import RxSwift

class TransactionTests: LocalhostNodeTest {
    
    private var aliceIdentity: AbstractIdentity!
    private var bobIdentity: AbstractIdentity!
    private var application: RadixApplicationClient!
    private var alice: Address!
    private var bob: Address!
    private var carolAccount: Account!
    private var carol: Address!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        aliceIdentity = AbstractIdentity(alias: "Alice")
        bobIdentity = AbstractIdentity(alias: "Bob")
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobIdentity.activeAccount)
        carolAccount = Account()
        carol = application.addressOf(account: carolAccount)
    }
    
    func testBurnTransaction() {
        let (tokenCreation, fooToken) = try! application.createToken(
            name: "FooToken",
            symbol: "ALICE",
            description: "Created By Alice",
            supply: .mutable(initial: 35)
        )
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let transaction = Transaction {[
            BurnTokensAction(tokenDefinitionReference: fooToken, amount: 5, burner: alice),
            BurnTokensAction(tokenDefinitionReference: fooToken, amount: 10, burner: alice)
        ]}
        
        let atom = try! application.atomFrom(transaction: transaction, addressOfActiveAccount: alice)
        let atomToBurnActionMapper = DefaultAtomToBurnTokenMapper()
        guard let burnActions: [BurnTokensAction] = atomToBurnActionMapper.mapAtomToActions(atom).blockingTakeFirst(1, timeout: 1) else { return }
        XCTAssertEqual(burnActions.count, 2)
        let burnActionZero = burnActions[0]
        XCTAssertEqual(burnActionZero.amount, 5)
        XCTAssertEqual(burnActionZero.burner, alice)
        XCTAssertEqual(burnActionZero.tokenDefinitionReference, fooToken)
        let burnActionOne = burnActions[1]
        XCTAssertEqual(burnActionOne.amount, 10)
        XCTAssertEqual(burnActionOne.burner, alice)
        XCTAssertEqual(burnActionOne.tokenDefinitionReference, fooToken)
    }
    
    private let bag = DisposeBag()
    func testTransactionWithMintPutUnique() {
        let (tokenCreation, fooToken) = try! application.createToken(
            name: "FooToken",
            symbol: "ALICE",
            description: "Created By Alice",
            supply: .mutable(initial: 35)
        )
        
        application.observeTransactions(at: alice).subscribe(onNext: {
            print("✅ tx: \($0)")
        }).disposed(by: bag)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let mintAndUniqueTx = Transaction {[
            MintTokensAction(tokenDefinitionReference: fooToken, amount: 5, minter: alice),
            PutUniqueIdAction(uniqueMaker: alice, string: "mint")
        ]}
        
        XCTAssertTrue(
            application.send(transaction: mintAndUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let burnAndUniqueTx = Transaction {[
            BurnTokensAction.init(tokenDefinitionReference: fooToken, amount: 5, burner: alice),
            PutUniqueIdAction(uniqueMaker: alice, string: "burn")
        ]}
        
        XCTAssertTrue(
            application.send(transaction: burnAndUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        let onlyUniqueTx = Transaction {[
            PutUniqueIdAction(uniqueMaker: alice, string: "unique")
        ]}

        XCTAssertTrue(
            application.send(transaction: onlyUniqueTx)
                // THEN: the Transaction is successfully sent
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )
  
        
        guard let putUniqueTransactions = application.observeTransactions(at: alice, containingActionOfAnyType: [PutUniqueIdAction.self]).blockingArrayTakeFirst(3, timeout: 1) else { return }
        XCTAssertEqual(
            putUniqueTransactions.flatMap { $0.actions(ofType: PutUniqueIdAction.self) }.map { $0.string },
            ["mint", "burn", "unique"]
        )
        
        guard let burnTxs = application.observeTransactions(at: alice, containingActionOfAnyType: [BurnTokensAction.self]).blockingArrayTakeFirst(1, timeout: 1) else { return }
        XCTAssertEqual(burnTxs.count, 1)
        XCTAssertEqual(burnTxs[0].actions.count, 2)

        guard let burnOrMintTransactions = application.observeTransactions(at: alice, containingActionOfAnyType: [BurnTokensAction.self, MintTokensAction.self]).blockingArrayTakeFirst(2, timeout: 1) else { return }

        XCTAssertEqual(burnOrMintTransactions.count, 2)

        guard let uniqueBurnTransactions = application.observeTransactions(at: alice, containingActionsOfAllTypes: [PutUniqueIdAction.self, BurnTokensAction.self]).blockingTakeFirst() else { return }

        guard case let uniqueActionInBurnTxs = uniqueBurnTransactions.actions(ofType: PutUniqueIdAction.self), let uniqueActionInBurnTx = uniqueActionInBurnTxs.first else { return XCTFail("Expected UniqueAction") }
        XCTAssertEqual(uniqueActionInBurnTx.string, "burn")
        
        guard let uniqueMintTransactions = application.observeTransactions(at: alice, containingActionsOfAllTypes: [PutUniqueIdAction.self, MintTokensAction.self]).blockingTakeFirst() else { return }
        
        guard case let uniqueActionInMintTxs = uniqueMintTransactions.actions(ofType: PutUniqueIdAction.self), let uniqueActionInMintTx = uniqueActionInMintTxs.first else { return XCTFail("Expected UniqueAction") }
        XCTAssertEqual(uniqueActionInMintTx.string, "mint")
    }
}
