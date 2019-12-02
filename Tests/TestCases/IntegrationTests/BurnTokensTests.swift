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
import Combine

class BurnTokensTests: IntegrationTest {
    
    func testMintBurnMintBurn() throws {
        
        let createTokenAction = aliceApp.actionCreateMultiIssuanceToken()
        let fooToken = createTokenAction.identifier
        
        try waitForTransactionToFinish(aliceApp.createToken(action: createTokenAction))
        
        let tokenContext = TokenContext(rri: fooToken, actor: alice)
        
        let transaction = Transaction(tokenContext) {
            Mint(amount: 100)   // 100
            Burn(amount: 3)     // 97
            Mint(amount: 5)     // 102
            Burn(amount: 7)     // 95
        }
        
        let pendingTransaction = aliceApp.make(transaction: transaction)
        
        try waitForTransactionToFinish(pendingTransaction)
        
        let tokenState = try waitForFirstValue(of: aliceApp.observeTokenState(identifier: fooToken))
        
        XCTAssertEqual(tokenState.totalSupply, 95)
    }
    
    // TODO when https://radixdlt.atlassian.net/browse/BS-196 is fixed, this test should pass, Radix Core beta2 broke the expected ordering of particles.
    func testMintBurnMintBurnMint() throws {
        print("test 'testMintBurnMintBurnMint' is commented out awaiting fix 'BS-196' (Jira ticket number)")
//        let createTokenAction = aliceApp.actionCreateMultiIssuanceToken()
//        let fooToken = createTokenAction.identifier
//
//       try waitForTransactionToFinish(aliceApp.createToken(action: createTokenAction))
//
//        let tokenContext = TokenContext(rri: fooToken, actor: alice)
//
//        let transaction = Transaction(tokenContext) {
//            Mint(amount: 100)   // 100
//            Burn(amount: 3)     // 97
//            Mint(amount: 5)     // 102
//            Burn(amount: 7)     // 95
//            Mint(amount: 13)    // 108
//            Burn(amount: 17)    // 91
//        }
//
//        let pendingTransaction = aliceApp.make(transaction: transaction)
//
//        try waitForTransactionToFinish(pendingTransaction)
//
//        let tokenState = try waitForFirstValue(of: aliceApp.observeTokenState(identifier: fooToken))
//        XCTAssertEqual(tokenState.totalSupply, 91)
    }
    
    func testBurnSuccessful() throws {
        
        // GIVEN: Radix identity Alice and an application layer action BurnToken
        let (tokenCreation, fooToken) = aliceApp.createToken(supply: .mutable(initial: 35))
        
        try waitForTransactionToFinish(tokenCreation)
        
        /// GIVEN: And a previously created FooToken, for which Alice has the appropriate permissions
        let fooTokenStateAfterCreation = try waitForFirstValue(of: aliceApp.observeTokenState(identifier: fooToken))
        XCTAssertEqual(fooTokenStateAfterCreation.totalSupply, 35)
        
        let myBalanceAfterCreate = try waitForFirstValueUnwrapped(of: aliceApp.observeMyBalance(ofToken: fooToken))
        XCTAssertEqual(myBalanceAfterCreate.amount, 35)
        
        // WHEN: Alice call Burn for FooToken
        let burning = aliceApp.burnTokens(amount: 2, ofType: fooToken)
        
        // THEN: the burning succeeds
        try waitForTransactionToFinish(burning)
        
        // THEN: AND the supply of FooToken is changed
        let fooTokenStateAfterBurn = try waitForFirstValue(of: aliceApp.observeTokenState(identifier: fooToken))
        XCTAssertEqual(fooTokenStateAfterBurn.totalSupply, 33)
        
        let myBalanceAfterBurn = try waitForFirstValueUnwrapped(of: aliceApp.observeMyBalance(ofToken: fooToken))
        
        // THEN: AND that Alice balance is reduced
        XCTAssertEqual(myBalanceAfterBurn.amount, 33)
    }
    
    func testBurnFailsDueUnknownRRI() throws {
        // GIVEN: Radix identity Alice and an application layer action BurnToken
        
        // WHEN Alice call Burn on RRI for some non existing FoobarToken
        let foobarToken: ResourceIdentifier = "/\(alice!)/FoobarToken"
        let burning = aliceApp.burnTokens(amount: 123, ofType: foobarToken)
        
        // THEN: an error unknownToken is thrown
        try waitFor(burning: burning, toFailWithError: .consumeError(.unknownToken(identifier: foobarToken)))
    }
    
    func testBurnFailDueToExceedingBalance() throws {
        // GIVEN: Radix identity Alice and an application layer action BurnToken and a previously created FooToken which has a supply of max - 10 tokens, for which Alice has the appropriate permissions.
        let (tokenCreation, fooToken) = aliceApp.createToken(supply: .mutable(initial: 10))
        try waitForTransactionToFinish(tokenCreation)
        
        // WHEN: Alice call Burn(20) on FooToken
        let burning = aliceApp.burnTokens(amount: 20, ofType: fooToken)
        
        // THEN: an error supplyExceedsMax is thrown
        try waitFor(
            burning: burning,
            toFailWithError: .insufficientTokens(
                token: fooToken,
                balance: 10,
                triedToBurnAmount: 20
            )
        )
    }
    
    func testBurnFailDueToWrongPermissions() throws {
        // GIVEN: Radix identity Alice and an application layer action BurnToken ...
        let bobApp = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.default, identity: bobIdentity)
        
        // GIVEN: ... and a previously created FooToken, for which Alice does **NOT** have the appropriate permissions
        let (tokenCreation, fooToken) = bobApp.createToken(supply: .mutable(initial: 1000))
        
        try waitForTransactionToFinish(tokenCreation)
        
        let cancellableSubscriptionOfBobsAddress = aliceApp.pull(address: bob)
        
        _ = try waitForFirstValue(
            of: aliceApp.observeTokenDefinitions(at: bob),
            description: "Alice needs to know about tokens defined by Bob"
        )
        
        // WHEN: Alice call Burn for FooToken
        let burning = aliceApp.burnTokens(amount: 100, ofType: fooToken)
        
        // THEN: an error unknownToken is thrown
        try waitFor(
            burning: burning,
            toFailWithError: .lackingPermissions(
                of: alice,
                toBurnToken: fooToken,
                whichRequiresPermission: .tokenOwnerOnly,
                creatorOfToken: bob
            )
        )
        
        XCTAssertNotNil(cancellableSubscriptionOfBobsAddress)
        cancellableSubscriptionOfBobsAddress.cancel()
    }
    
    func testFailingBurnAliceTriesToBurnCarolsCoins() throws {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        
        let (tokenCreation, fooToken) = aliceApp.createMultiIssuanceToken(initialSupply: 1000)
        
        try waitForTransactionToFinish(tokenCreation)
        
        // WHEN: Alice tries to burn Carols coins
        let burning = aliceApp.burnTokens(
            action: BurnTokensAction(tokenDefinitionReference: fooToken, amount: 10, burner: carol)
        )
        
        // THEN: I see that it fails
        try waitFor(
            burning: burning,
            toFailWithError: .consumeError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: carol))
        )
    }
    
    func testBurnFailDueToSupplyBeingFixed() throws {
        // GIVEN: Radix identity Alice and an application layer action BurnToken, and a previously created FooToken, which has FIXED supply
        let (tokenCreation, fooToken) = aliceApp.createFixedSupplyToken(supply: 10)
        
        try waitForTransactionToFinish(tokenCreation)
        
        // WHEN: Alice call Burn for FooToken
        let burning = aliceApp.burnTokens(amount: 2, ofType: fooToken)
        
        // THEN: I see that it fails
        try waitFor(
            burning: burning,
            toFailWithError: .tokenHasFixedSupplyThusItCannotBeBurned(identifier: fooToken)
        )
    }
    
    func testBurnFailDueToIncorrectGranularity() throws {
        // GIVEN: Radix identity Alice and an application layer action BurnToken, and a previously created FooToken, with a granularity of 3
        let (tokenCreation, fooToken) = aliceApp.createMultiIssuanceToken(initialSupply: 30, granularity: 3)
        
        try waitForTransactionToFinish(tokenCreation)
        
        // WHEN: Alice call Burn(2) for FooToken, where 3∤2 (3 does not divide 2)
        let burning = aliceApp.burnTokens(amount: 2, ofType: fooToken)
        
        // THEN: I see that it fails
        try waitFor(
            burning: burning,
            toFailWithError: .consumeError(
                .amountNotMultipleOfGranularity(
                    token: fooToken,
                    triedToConsumeAmount: 2,
                    whichIsNotMultipleOfGranularity: 3
                )
            )
        )
    }
}

private extension BurnTokensTests {
    
    func waitFor(
        burning pendingTransaction: PendingTransaction,
        toFailWithError burnError: BurnError,
        description: String? = nil,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        
        try waitForAction(
            ofType: BurnTokensAction.self,
            in: pendingTransaction,
            description: description
        ) { burnTokensAction in
            
            TransactionError.actionsToAtomError(
                .burnTokensActionError(
                    burnError,
                    action: burnTokensAction
                )
            )
        }
    }
}
