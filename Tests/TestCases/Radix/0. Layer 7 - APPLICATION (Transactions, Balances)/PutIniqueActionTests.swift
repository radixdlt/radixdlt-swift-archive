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
    private var fooToken: ResourceIdentifier!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        aliceIdentity = AbstractIdentity(alias: "Alice")
        bobAccount = Account()
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobAccount)
        
        let (tokenCreation, rri) = try! application.createToken(
            name: "FooToken",
            symbol: "FOO",
            description: "Fooest token ever",
            supply: .mutableZeroSupply
        )

        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        fooToken = rri
    }
    
    func testAC1() {

        let transaction = Transaction {[
            MintTokensAction(tokenDefinitionReference: fooToken, amount: 1, minter: alice),
            PutUniqueIdAction(uniqueMaker: alice, string: "Baz")
        ]}
        
        XCTAssertTrue(
            application.send(transaction: transaction)
                .blockingWasSuccessfull(timeout: .enoughForPOW)
        )

        guard let executedTransaction: ExecutedTransaction = application.observeTransactions(at: alice, containingActionOfAnyType: [PutUniqueIdAction.self]).blockingTakeFirst(timeout: 1) else { return }

        let putUniqueActions = executedTransaction.actions(ofType: PutUniqueIdAction.self)

        XCTAssertEqual(putUniqueActions.count, 1)
        let putUniqueAction = putUniqueActions[0]
        XCTAssertEqual(putUniqueAction.string, "Baz")
    }
}
