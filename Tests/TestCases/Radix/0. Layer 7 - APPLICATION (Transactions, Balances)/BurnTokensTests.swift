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

class BurnTokensTests: LocalhostNodeTest {
    
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
    
    private let disposeBag = DisposeBag()

    
    func testBurnMintBurnMintBurnMint() {
        
        let createTokenAction = application.actionCreateMultiIssuanceToken()
        let fooToken = createTokenAction.identifier
        
        func burn(amount: PositiveAmount) -> UserAction {
            return BurnTokensAction(tokenDefinitionReference: fooToken, amount: amount, burner: alice)
        }
        
        func mint(amount: PositiveAmount) -> UserAction {
            return MintTokensAction(tokenDefinitionReference: fooToken, amount: amount, minter: alice)
        }
    
        let transaction = Transaction {[
            createTokenAction,
            mint(amount: 100),   // 100
            burn(amount: 3),     // 97
            mint(amount: 5),     // 102
            burn(amount: 7),    // 95
            mint(amount: 13),    // 108
            burn(amount: 17),    // 91
        ]}
        
        let result = application.send(transaction: transaction)

        XCTAssertTrue(
            result.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        guard let tokenState = application.observeTokenState(identifier: fooToken).blockingTakeFirst(timeout: .enoughForPOW) else { return }
        XCTAssertEqual(tokenState.totalSupply, 91)
    }
    
    func testBurnSuccessful() {
        
        // GIVEN: Radix identity Alice and an application layer action BurnToken
        let (tokenCreation, fooToken) = application.createToken(supply: .mutable(initial: 35))
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        /// GIVEN: And a previously created FooToken, for which Alice has the appropriate permissions
        guard let fooTokenStateAfterCreation = application.observeTokenState(identifier: fooToken).blockingTakeFirst() else { return }
        XCTAssertEqual(fooTokenStateAfterCreation.totalSupply, 35)

        guard let myBalanceOrNilAfterCreate = application.observeMyBalance(ofToken: fooToken).blockingTakeLast() else { return }
        guard let myBalanceAfterCreate = myBalanceOrNilAfterCreate else { return XCTFail("Expected non nil balance") }
        XCTAssertEqual(myBalanceAfterCreate.amount, 35)

        // WHEN: Alice call Burn for FooToken
        let burning = application.burnTokens(amount: 2, ofType: fooToken)
        
        XCTAssertTrue(
            // THEN: the burning succeeds
            burning.blockingWasSuccessfull(timeout: .enoughForPOW)
        
        )
        // THEN: AND the supply of FooToken is changed
        guard let fooTokenStateAfterBurn = application.observeTokenState(identifier: fooToken).blockingTakeLast() else { return }
        XCTAssertEqual(fooTokenStateAfterBurn.totalSupply, 33)


        guard let myBalanceOrNilAfterBurn = application.observeMyBalance(ofToken: fooToken).blockingTakeLast() else { return }
        guard let myBalanceAfterBurn = myBalanceOrNilAfterBurn else { return XCTFail("Expected non nil balance") }
        // THEN: AND that Alice balance is reduced
        XCTAssertEqual(myBalanceAfterBurn.amount, 33)
        
    }
    
    func testBurnFailsDueUnknownRRI() {
        // GIVEN: Radix identity Alice and an application layer action BurnToken
        
        // WHEN Alice call Burn on RRI for some nonexisting FoobarToken
        let foobarToken: ResourceIdentifier = "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/FoobarToken"
        let burning = application.burnTokens(amount: 123, ofType: foobarToken)
        
        // THEN: an error unknownToken is thrown
        burning.blockingAssertThrows(
            error: BurnError.consumeError(.unknownToken(identifier: foobarToken))
        )
    }
    
    func testBurnFailsDueToExceedingBalance() {
        // GIVEN: Radix identity Alice and an application layer action BurnToken
        
        // GIVEN: ... and a previously created FooToken which has a supply of max - 10 tokens, for which Alice has the appropriate permissions.
        let (tokenCreation, fooToken) = application.createToken(supply: .mutable(initial: 10))
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: Alice call Burn(20) on FooToken
        let burning = application.burnTokens(amount: 20, ofType: fooToken)
        
        // THEN: an error supplyExcceedsMax is thrown
        burning.blockingAssertThrows(
            error: BurnError.insufficientTokens(
                token: fooToken,
                balance: 10,
                triedToBurnAmount: 20
            )
        )
    }
    
    func testBurnFailDueToWrongPermissions() {
        // GIVEN: Radix identity Alice and an application layer action BurnToken ...
        let bobApp = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: bobIdentity)
        let aliceApp = application!
        
        // GIVEN: ... and a previously created FooToken, for which Alice does **NOT** have the appropriate permissions
        let (tokenCreation, fooToken) = bobApp.createToken(supply: .mutable(initial: 1000))
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        aliceApp.pull(address: bob).disposed(by: disposeBag)
        guard let _ = aliceApp.observeTokenDefinitions(at: bob).blockingTakeFirst(timeout: 5) else { return XCTFail("Alice needs to know about tokens defined by Bob") }
        
        // WHEN: Alice call Burn for FooToken
        let burning = aliceApp.burnTokens(amount: 100, ofType: fooToken)
        
        // THEN: an error unknownToken is thrown
        burning.blockingAssertThrows(
            error: BurnError.lackingPermissions(
                of: alice,
                toBurnToken: fooToken,
                whichRequiresPermission: .tokenOwnerOnly,
                creatorOfToken: bob
            )
        )
    }
    
    func testFailingBurnAliceTriesToBurnCarolsCoins() {
        // GIVEN: a RadixApplicationClient and identities Alice and Bob
        
        let (tokenCreation, fooToken) = application.createMultiIssuanceToken(initialSupply: 1000)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: Alice tries to burn Carols coins
        let transfer = application.burnTokens(BurnTokensAction(tokenDefinitionReference: fooToken, amount: 10, burner: carol))
        
        // THEN: I see that it fails
        transfer.blockingAssertThrows(
            error: BurnError.consumeError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: carol))
        )
    }
    
    func testBurnFailDueToSupplyBeingFixed() {
        // GIVEN: Radix identity Alice and an application layer action BurnToken, and a previously created FooToken, which has FIXED supply
        let (tokenCreation, fooToken) = application.createFixedSupplyToken(supply: 10)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: Alice call Burn for FooToken
        let burning = application.burnTokens(amount: 2, ofType: fooToken)
        
        // THEN: an error unknownToken is thrown
        burning.blockingAssertThrows(
            error: BurnError.tokenHasFixedSupplyThusItCannotBeBurned(identifier: fooToken)
        )
        
    }
    
    func testBurnFailDueToIncorrectGranularity() {
        // GIVEN: Radix identity Alice and an application layer action BurnToken, and a previously created FooToken, with a granularity of 3
        let (tokenCreation, fooToken) = application.createMultiIssuanceToken(initialSupply: 30, granularity: 3)
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: Alice call Burn(2) for FooToken, where 3∤2 (3 does not divide 2)
        let burning = application.burnTokens(amount: 2, ofType: fooToken)
        
        burning.blockingAssertThrows(
            error: BurnError.consumeError(
                .amountNotMultipleOfGranularity(
                    token: fooToken,
                    triedToConsumeAmount: 2,
                    whichIsNotMultipleOfGranularity: 3
                )
            )
        )
        
    }
    
}
