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

class TokenBalancesTests: TestCase {
    
    private let address = Address.irrelevant
    private lazy var rriFoo = ResourceIdentifier(address: address, name: "FOO")
    private lazy var tokenFoo = TokenDefinition(rri: rriFoo)
    private lazy var tokenBalanceFoo = TokenBalance(token: tokenFoo, amount: 42, owner: address)
    private lazy var rriBar = ResourceIdentifier(address: address, name: "BAR")
    private lazy var tokenBar = TokenDefinition(rri: rriBar)
    private lazy var tokenBalanceBar = TokenBalance(token: tokenBar, amount: 237, owner: address)
    

    func testMergeNoDuplicates() throws {
        
        let old: TokenBalances = [rriFoo: tokenBalanceFoo]
        let new: TokenBalances = [rriBar: tokenBalanceBar]
        XCTAssertEqual(old.count, 1)
        XCTAssertEqual(new.count, 1)
        XCTAssertEqual(old.balance(ofToken: rriFoo)?.amount, 42)
        XCTAssertEqual(new.balance(ofToken: rriBar)?.amount, 237)
        let merged = try old.merging(with: new)
        XCTAssertEqual(merged.count, 2)
        XCTAssertEqual(merged.balance(ofToken: rriFoo)?.amount, 42)
        XCTAssertEqual(merged.balance(ofToken: rriBar)?.amount, 237)
        
    }
    
    func testMergeDuplicateAssertKeepNew() throws {
        let fooFirst = TokenBalance(token: tokenFoo, amount: 42, owner: address)
        let fooSecond = TokenBalance(token: tokenFoo, amount: 1337, owner: address)
        
        let old: TokenBalances = [rriFoo: fooFirst]
        let new: TokenBalances = [rriFoo: fooSecond]
        XCTAssertEqual(old.count, 1)
        XCTAssertEqual(new.count, 1)
        XCTAssertEqual(old.balance(ofToken: rriFoo)?.amount, 42)
        XCTAssertEqual(new.balance(ofToken: rriFoo)?.amount, 1337)
        XCTAssertNil(new.balance(ofToken: rriBar))
        XCTAssertNil(old.balance(ofToken: rriBar))
        
        let merged = try old.merging(with: new)
        XCTAssertEqual(merged.count, 1)
        XCTAssertEqual(merged.balance(ofToken: rriFoo)?.amount, 1337)
        
    }
    
    func testMergeNoDuplicatesAliceOfTokenSheHasNotCreated() throws {
        let alice = Address.irrelevant(index: 1)
        
        let aliceTokenBalanceFoo = TokenBalance(token: tokenFoo, amount: 42, owner: alice)
        let aliceTokenBalanceBar = TokenBalance(token: tokenBar, amount: 237, owner: alice)

        let aliceBalanceOfFoo: TokenBalances = [rriFoo: aliceTokenBalanceFoo]
        let aliceBalanceOfBar: TokenBalances = [rriBar: aliceTokenBalanceBar]
        
        XCTAssertEqual(aliceBalanceOfFoo.count, 1)
        XCTAssertEqual(aliceBalanceOfBar.count, 1)
        XCTAssertEqual(aliceBalanceOfFoo.balance(ofToken: rriFoo)?.amount, 42)
        XCTAssertEqual(aliceBalanceOfBar.balance(ofToken: rriBar)?.amount, 237)
        let merged = try aliceBalanceOfFoo.merging(with: aliceBalanceOfBar)
        XCTAssertEqual(merged.count, 2)
        XCTAssertEqual(merged.balance(ofToken: rriFoo)?.amount, 42)
        XCTAssertEqual(merged.balance(ofToken: rriBar)?.amount, 237)
        XCTAssertEqual(merged.balance(ofToken: rriFoo)?.owner, alice)
        XCTAssertEqual(merged.balance(ofToken: rriBar)?.owner, alice)
        
    }
    
    func testMergeDuplicateAssertKeepNewAliceOfTokenSheHasNotCreated() throws {
        
        let alice = Address.irrelevant(index: 1)
        
        let aliceTokenBalanceFooFirst = TokenBalance(token: tokenFoo, amount: 42, owner: alice)
        let aliceTokenBalanceFooSecond = TokenBalance(token: tokenFoo, amount: 1337, owner: alice)
        
        let old: TokenBalances = [rriFoo: aliceTokenBalanceFooFirst]
        let new: TokenBalances = [rriFoo: aliceTokenBalanceFooSecond]
        
        XCTAssertEqual(old.count, 1)
        XCTAssertEqual(new.count, 1)
        XCTAssertEqual(old.balance(ofToken: rriFoo)?.amount, 42)
        XCTAssertEqual(new.balance(ofToken: rriFoo)?.amount, 1337)
        XCTAssertNil(new.balance(ofToken: rriBar))
        XCTAssertNil(old.balance(ofToken: rriBar))
        
        let merged = try old.merging(with: new)
        
        XCTAssertEqual(merged.count, 1)
        let aliceBalanceOfFoo = try XCTUnwrap(merged.balance(ofToken: rriFoo))
        XCTAssertEqual(aliceBalanceOfFoo.amount, 1337)
        XCTAssertEqual(aliceBalanceOfFoo.owner, alice)
        
    }
    
    func testAssertThrowingWhenDifferentOwnersOfSameTokenBeingMerged() {
        let alice = Address.irrelevant(index: 1)
        let aliceTokenBalanceFoo = TokenBalance(token: tokenFoo, amount: 42, owner: alice)
        let aliceBalanceOfFoo: TokenBalances = [rriFoo: aliceTokenBalanceFoo]
        
        let bob = Address.irrelevant(index: 2)
        let bobTokenBalanceFoo = TokenBalance(token: tokenFoo, amount: 1337, owner: bob)
        let bobBalanceOfFoo: TokenBalances = [rriFoo: bobTokenBalanceFoo]
        
        XCTAssertThrowsSpecificError(
            try aliceBalanceOfFoo.merging(with: bobBalanceOfFoo),
            TokenBalances.Error.mergingTokenBalancesWithDifferentOwners(last: alice, new: bob)
        )
    }
    
    func testAssertThrowingErrorWhenListOfTokenBalanceContainingDuplicates() {
        let bob = Address.irrelevant(index: 2)
        let fooFirst = TokenBalance(token: tokenFoo, amount: 42, owner: bob)
        let fooSecond = TokenBalance(token: tokenFoo, amount: 1337, owner: bob)
        
        XCTAssertThrowsSpecificError(
            try TokenBalances(balances: [fooFirst, fooSecond]),
            TokenBalances.Error.tokenBalanceArrayContainsDuplicateEntries(last: fooFirst, new: fooSecond)
        )
    }
    
    func testAssertThatNoErorrIsThrownWhenTwoDifferentVersionsOfTokenDefinitionIsMerged() throws {
        let alice = Address.irrelevant(index: 1)
        
        let tokenFooVersionSupply1000 = TokenDefinition(rri: rriFoo, supply: 1_000)
        let tokenFooVersionSupply2000 = TokenDefinition(rri: rriFoo, supply: 2_000) // updated version
        
        let aliceTokenBalanceFooS1k = TokenBalance(token: tokenFooVersionSupply1000, amount: 42, owner: alice)
        let aliceBalanceOfFooS1k: TokenBalances = [rriFoo: aliceTokenBalanceFooS1k]

        let aliceTokenBalanceFooS2k = TokenBalance(token: tokenFooVersionSupply2000, amount: 237, owner: alice)
        let aliceBalanceOfFooS2k: TokenBalances = [rriFoo: aliceTokenBalanceFooS2k]


        let mergedMaybe = XCTAssertNotThrows(try aliceBalanceOfFooS1k.merging(with: aliceBalanceOfFooS2k))
        let merged = try XCTUnwrap(mergedMaybe)
        XCTAssertEqual(merged.balancePerToken.count, 1)
        let aliceBalanceOfFoo = try XCTUnwrap(merged.balance(ofToken: rriFoo))
        XCTAssertEqual(aliceBalanceOfFoo.owner, alice)
        XCTAssertEqual(aliceBalanceOfFoo.amount, 237)
        let supplyOfFoo = try XCTUnwrap(aliceBalanceOfFoo.token.supply)
        XCTAssertEqual(supplyOfFoo, 2000)
    }
}
