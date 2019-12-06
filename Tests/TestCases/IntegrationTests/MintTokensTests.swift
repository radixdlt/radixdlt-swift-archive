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

private extension Supply {
    static let ten: Supply = 10
}

class MintTokensTests: IntegrationTest {
    
    func testMintSuccessful() throws {
        
        // GIVEN: Radix identity Alice and an application layer action MintToken
        let (tokenCreation, fooToken) = applicationClient.createToken(supply: .mutable(initial: 30))
        try waitForTransactionToFinish(tokenCreation)
        
        /// GIVEN: And a previously created FooToken, for which Alice has the appropriate permissions
        let fooTokenStateAfterCreation = try waitForFirstValue(of: applicationClient.observeTokenState(identifier: fooToken))
        XCTAssertEqual(fooTokenStateAfterCreation.totalSupply, 30)

        let myBalanceAfterCreate = try waitForFirstValueUnwrapped(of: applicationClient.observeMyBalance(ofToken: fooToken))
        XCTAssertEqual(myBalanceAfterCreate.amount, 30)

        // WHEN: Alice call Mint(42) for FooToken
        let minting = applicationClient.mintTokens(amount: 42, ofType: fooToken)

        // THEN: the minting succeeds
        try waitForTransactionToFinish(minting)

        // THEN: AND the supply of FooToken is updated with 42
        let fooTokenStateAfterMint = try waitForFirstValue(of: applicationClient.observeTokenState(identifier: fooToken))
        XCTAssertEqual(fooTokenStateAfterMint.totalSupply, 72)

        let myBalanceAfterMint = try waitForFirstValueUnwrapped(of: applicationClient.observeMyBalance(ofToken: fooToken))

        // THEN: AND that these new 42 tokens belong to Alice
        XCTAssertEqual(myBalanceAfterMint.amount, 72)
    }

    func testMintFailsDueUnknownRRI() throws {
        // GIVEN: Radix identity Alice and an application layer action MintToken
        
        // WHEN Alice call Mint on RRI for some non existing token
        let unknownRRI: ResourceIdentifier = "/\(bob!)/Unknown"
        let minting = applicationClient.mintTokens(amount: 123, ofType: unknownRRI)
        
        // THEN: an error unknownToken is thrown
        try waitFor(
            minting: minting,
            toFailWithError: .unknownToken(identifier: unknownRRI)
        )
    }
    
    func testMintFailsDueToExceedingTheGreatestPossibleSupply() throws {
        // GIVEN: Radix identity Alice and an application layer action MintToken
        
        // GIVEN: ... and a previously created FooToken which has a supply of max - 10 tokens, for which Alice has the appropriate permissions.
        let (tokenCreation, fooToken) = try applicationClient.createToken(
            name: "FooToken",
            symbol: "ALICE",
            description: "Created By Alice",
            supply: .mutable(initial: Supply(subtractedFromMax: Supply.ten))
        )
        
       try waitForTransactionToFinish(tokenCreation)
        
        // WHEN: Alice call Mint(20) on FooToken
        let minting = applicationClient.mintTokens(amount: 20, ofType: fooToken)
        
        // THEN: an error supplyExceedsMax is thrown
        try waitFor(
            minting: minting,
            toFailWithError: .tokenOverMint(
                token: fooToken,
                maxSupply: Supply.max,
                currentSupply: try Supply(subtractedFromMax: Supply.ten),
                byMintingAmount: 20
            )
        )
    }
    
    
    func testMintFailDueToWrongPermissions() throws {
        // GIVEN: Radix identity Alice and an application layer action MintToken ...
        applicationClient.changeAccount(to: bobAccount)
        
        // GIVEN: ... and a previously created FooToken, for which Alice does **NOT** have the appropriate permissions
        let (tokenCreation, fooToken) = try applicationClient.createToken(
            supply: .mutable(initial: Supply(subtractedFromMax: Supply.ten))
        )
        
        try waitForTransactionToFinish(tokenCreation)
        applicationClient.changeAccount(to: aliceAccount)
        
        let cancellableSubscriptionOfBobsAddress = applicationClient.pull(address: bob)
        _ = try waitForFirstValue(
            of: applicationClient.observeTokenDefinitions(at: bob),
            description: "Alice needs to know about tokens defined by Bob"
        )
        
        // WHEN: Alice call Mint for FooToken
        let minting = applicationClient.mintTokens(amount: 123, ofType: fooToken)
        
        // THEN: an error unknownToken is thrown
        try waitFor(
            minting: minting,
            toFailWithError: .lackingPermissions(
                of: alice,
                toMintToken: fooToken,
                whichRequiresPermission: .tokenOwnerOnly,
                creatorOfToken: bob
            )
        )

        XCTAssertNotNil(cancellableSubscriptionOfBobsAddress)
        cancellableSubscriptionOfBobsAddress.cancel()
    }
    
    func testMintFailDueToSupplyBeingFixed() throws {
        // GIVEN: Radix identity Alice and an application layer action MintToken, and a previously created FooToken, which has FIXED supply
        let (tokenCreation, fooToken) = applicationClient.createToken(supply: .fixed(to: 10))
        
        try waitForTransactionToFinish(tokenCreation)
        
        // WHEN: Alice call Mint for FooToken
        let minting = applicationClient.mintTokens(amount: 2, ofType: fooToken)
        
        // THEN: an error is thrown
        try waitFor(
            minting: minting,
            toFailWithError: .tokenHasFixedSupplyThusItCannotBeMinted(identifier: fooToken)
        )
    }
    
    func testMintFailDueToIncorrectGranularity() throws {
        // GIVEN: Radix identity Alice and an application layer action MintToken, and a previously created FooToken, with a granularity of 3
        let (tokenCreation, fooToken) = applicationClient.createToken(
            supply: .mutable(initial: 30),
            granularity: 3
        )
        try waitForTransactionToFinish(tokenCreation)
        
        
        // WHEN: Alice call Mint(2) for FooToken, where 3∤2 (3 does not divide 2)
        let minting = applicationClient.mintTokens(amount: 2, ofType: fooToken)
        
        // THEN: an error is thrown
        try waitFor(
            minting: minting,
            toFailWithError: .amountNotMultipleOfGranularity(
                token: fooToken,
                triedToMintAmount: 2,
                whichIsNotMultipleOfGranularity: 3
            )
        )
    }
}

private extension MintTokensTests {
    
    func waitFor(
        minting pendingTransaction: PendingTransaction,
        toFailWithError mintError: MintError,
        description: String? = nil,
        timeout: TimeInterval = .enoughForPOW,
        line: UInt = #line
    ) throws {
        
        try waitForAction(
            ofType: MintTokensAction.self,
            in: pendingTransaction,
            description: description,
            line: line
        ) { mintTokensAction in
            
            TransactionError.actionsToAtomError(
                .mintTokensActionError(
                    mintError,
                    action: mintTokensAction
                )
            )
        }
    }
}
