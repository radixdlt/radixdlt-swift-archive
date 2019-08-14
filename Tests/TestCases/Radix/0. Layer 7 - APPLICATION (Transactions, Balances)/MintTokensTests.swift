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

class MintTokensTests: LocalhostNodeTest {

    private var aliceIdentity: AbstractIdentity!
    private var bobIdentity: AbstractIdentity!
    private var application: RadixApplicationClient!
    private var alice: Address!
    private var bob: Address!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        aliceIdentity = AbstractIdentity(alias: "Alice")
        bobIdentity = AbstractIdentity(alias: "Bob")
        application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: aliceIdentity)
        alice = application.addressOfActiveAccount
        bob = application.addressOf(account: bobIdentity.activeAccount)
    }
    
    func testMintSuccessful() {
        
        // GIVEN: Radix identity Alice and an application layer action MintToken
        let (tokenCreation, fooToken) = try! application.createToken(
            name: "FooToken",
            symbol: "ALICE",
            description: "Created By Alice",
            defineSupply: .mutable(initial: 30)
        )
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        /// GIVEN: And a previously created FooToken, for which Alice has the appropriate permissions
        guard let fooTokenStateAfterCreation = application.observeTokenState(identifier: fooToken).blockingTakeFirst(timeout: 2) else { return }
        XCTAssertEqual(fooTokenStateAfterCreation.totalSupply, 30)
        
        guard let myBalanceOrNilAfterCreate = application.observeMyBalance(ofToken: fooToken).blockingTakeLast(timeout: 3) else { return }
        guard let myBalanceAfterCreate = myBalanceOrNilAfterCreate else { return XCTFail("Expected non nil balance") }
        XCTAssertEqual(myBalanceAfterCreate.amount, 30)
        
        // WHEN: Alice call Mint(42) for FooToken
        let minting = application.mintTokens(amount: 42, ofType: fooToken)
        
        XCTAssertTrue(
            // THEN: the minting succeeds
            minting.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // THEN: AND the supply of FooToken is updated with 42
        guard let fooTokenStateAfterMint = application.observeTokenState(identifier: fooToken).blockingTakeFirst(timeout: 2) else { return }
        XCTAssertEqual(fooTokenStateAfterMint.totalSupply, 72)
        
        
        guard let myBalanceOrNilAfterMint = application.observeMyBalance(ofToken: fooToken).blockingTakeLast(timeout: 3) else { return }
        guard let myBalanceAfterMint = myBalanceOrNilAfterMint else { return XCTFail("Expected non nil balance") }
        // THEN: AND that these new 42 tokens belong to Alice
        XCTAssertEqual(myBalanceAfterMint.amount, 72)
        
    }

    func testMintFailsDueUnknownRRI() {
        // GIVEN: Radix identity Alice and an application layer action MintToken
        
        // WHEN Alice call Mint on RRI for some nonexisting FoobarToken
        let foobarToken: ResourceIdentifier = "/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/FoobarToken"
        let minting = application.mintTokens(amount: 123, ofType: foobarToken)
        
        // THEN: an error unknownToken is thrown
        minting.blockingAssertThrows(
            error: MintError.unknownToken(identifier: foobarToken)
        )
    }
    
    func testMintFailsDueToExceedingTheGreatestPossibleSupply() {
        // GIVEN: Radix identity Alice and an application layer action MintToken
        
        // GIVEN: ... and a previously created FooToken which has a supply of max - 10 tokens, for which Alice has the appropriate permissions.
        let (tokenCreation, fooToken) = try! application.createToken(
            name: "FooToken",
            symbol: "ALICE",
            description: "Created By Alice",
            defineSupply: .mutable(initial: Supply(subtractingFromMax: 10))
        )
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: Alice call Mint(20) on FooToken
        let minting = application.mintTokens(amount: 20, ofType: fooToken)
        
        // THEN: an error supplyExcceedsMax is thrown
        minting.blockingAssertThrows(
            error: MintError.tokenOverMint(
                token: fooToken,
                maxSupply: Supply.max,
                currentSupply: try! Supply(subtractingFromMax: 10),
                byMintingAmount: 20
            )
        )
    }
    
    private let disposeBag = DisposeBag()
    
    func testMintFailDueToWrongPermissions() {
        // GIVEN: Radix identity Alice and an application layer action MintToken ...
        let bobApp = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: bobIdentity)
        let aliceApp = application!
        
        // GIVEN: ... and a previously created FooToken, for which Alice does **NOT** have the appropriate permissions
        let (tokenCreation, fooToken) = try! bobApp.createToken(
            name: "FooToken",
            symbol: "BOB",
            description: "Created By Bob",
            defineSupply: .mutable(initial: Supply(subtractingFromMax: 10))
        )
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        aliceApp.pull(address: bob).disposed(by: disposeBag)
        guard let _ = aliceApp.observeTokenDefinitions(at: bob).blockingTakeFirst(timeout: 5) else { return XCTFail("Alice needs to know about tokens defined by Bob") }
        
        // WHEN: Alice call Mint for FooToken
        let minting = aliceApp.mintTokens(amount: 123, ofType: fooToken)
        
        // THEN: an error unknownToken is thrown
        minting.blockingAssertThrows(
            error: MintError.lackingPermissions(
                of: alice,
                toMintToken: fooToken,
                whichRequiresPermission: .tokenOwnerOnly,
                creatorOfToken: bob
            )
        )
    }
    
    func testMintFailDueToSupplyBeingFixed() {
        // GIVEN: Radix identity Alice and an application layer action MintToken, and a previously created FooToken, which has FIXED supply
        let (tokenCreation, fooToken) = try! application.createToken(
            name: "FooToken",
            symbol: "ALICE",
            description: "Created By Alice",
            defineSupply: .fixed(to: 10)
        )
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )

        // WHEN: Alice call Mint for FooToken
        let minting = application.mintTokens(amount: 2, ofType: fooToken)
        
        // THEN: an error unknownToken is thrown
        minting.blockingAssertThrows(
            error: MintError.tokenHasFixedSupplyThusItCannotBeMinted(identifier: fooToken)
        )
        
    }
    
    func testMintFailDueToIncorrectGranularity() {
        // GIVEN: Radix identity Alice and an application layer action MintToken, and a previously created FooToken, with a granularity of 3
        let (tokenCreation, fooToken) = try! application.createToken(
            name: "FooToken",
            symbol: "ALICE",
            description: "Created By Alice",
            defineSupply: .mutable(initial: 30),
            granularity: 3
        )
        
        XCTAssertTrue(
            tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW)
        )
        
        // WHEN: Alice call Mint(2) for FooToken, where 3∤2 (3 does not divide 2)
        let minting = application.mintTokens(amount: 2, ofType: fooToken)
        
        minting.blockingAssertThrows(
            error: MintError.amountNotMultipleOfGranularity(
                token: fooToken,
                triedToMintAmount: 2,
                whichIsNotMultipleOfGranularity: 3
            )
        )
        
    }
    
}
