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

class MintTokensTests: LocalhostNodeTest {

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
    
    func testMintSuccessful() {
        
        // GIVEN: Radix identity Alice and an application layer action MintToken
        let (tokenCreation, fooToken) = try! application.createToken(
            name: "FooToken",
            symbol: "FOO",
            description: "Fooeset coin",
            supply: .mutable(initial: 30)
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

}
