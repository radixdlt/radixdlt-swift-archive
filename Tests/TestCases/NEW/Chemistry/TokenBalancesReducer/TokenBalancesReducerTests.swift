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

class TokenBalancesReducerTests: TestCase {
    
    func test_balance_of_single_token_balance_then_token_state() throws {
        
        let address = Address.irrelevant
        let rriFoo = ResourceIdentifier(address: address, name: "FOO")
        let tokenFoo = TokenDefinition(rri: rriFoo)
        
        let amountFoo: NonNegativeAmount = 5
        let supplyFoo: Supply = 100
        
        try doTestSingle(
            address: address,
            
            input: { balanceStateSubject, tokensStateSubject in
                balanceStateSubject.send([
                    rriFoo: TokenReferenceBalance(tokenResourceIdentifier: rriFoo, amount: amountFoo, owner: address)
                ])
                
                tokensStateSubject.send([
                    rriFoo: TokenDefinitionsState.Value.full(TokenState(token: tokenFoo, supply: supplyFoo))
                ])
            }
        ) { tokenBalance in
            XCTAssertEqual(tokenBalance.token.tokenDefinitionReference, rriFoo)
            XCTAssertEqual(tokenBalance.owner, address)
            XCTAssertEqual(tokenBalance.token.supply, supplyFoo)
            XCTAssertEqual(tokenBalance.amount, amountFoo)
        }
    }
    
    func test_balance_of_single_token_token_state_then_balance() throws {
        
        let address = Address.irrelevant
        let rriFoo = ResourceIdentifier(address: address, name: "FOO")
        let tokenFoo = TokenDefinition(rri: rriFoo)
        
        let amountFoo: NonNegativeAmount = 5
        let supplyFoo: Supply = 100
        
        try doTestSingle(
            address: address,
            
            input: { balanceStateSubject, tokensStateSubject in
                
                tokensStateSubject.send([
                    rriFoo: TokenDefinitionsState.Value.full(TokenState(token: tokenFoo, supply: supplyFoo))
                ])
                
                balanceStateSubject.send([
                    rriFoo: TokenReferenceBalance(tokenResourceIdentifier: rriFoo, amount: amountFoo, owner: address)
                ])
            
        }
        ) { tokenBalance in
            XCTAssertEqual(tokenBalance.token.tokenDefinitionReference, rriFoo)
            XCTAssertEqual(tokenBalance.owner, address)
            XCTAssertEqual(tokenBalance.token.supply, supplyFoo)
            XCTAssertEqual(tokenBalance.amount, amountFoo)
        }
    }
    
    
    func test_two_balance_updates_of_single_token() throws {
        
        let address = Address.irrelevant
        let symbol: Symbol = "FOO"
        let rri = ResourceIdentifier(address: address, symbol: symbol)
        let token = TokenDefinition(rri: rri)
        
        let supply: Supply = 100
        
        try doTest(
            address: address,
            expectedNumberOfOutputs: 2,
            input: { balanceStateSubject, tokensStateSubject in
                balanceStateSubject.send([
                    rri: TokenReferenceBalance(tokenResourceIdentifier: rri, amount: 42, owner: address)
                ])
                
                tokensStateSubject.send([
                    rri: TokenDefinitionsState.Value.full(TokenState(token: token, supply: supply))
                ])
                
                balanceStateSubject.send([
                    rri: TokenReferenceBalance(tokenResourceIdentifier: rri, amount: 237, owner: address)
                ])
        },
            
            assertCorrectnessOfOutput: { output in
                
                let firstTokenBalances = output[0]
                var tokenBalance = try XCTUnwrap(firstTokenBalances.balance(ofToken: rri))
                XCTAssertEqual(tokenBalance.token.tokenDefinitionReference, rri)
                XCTAssertEqual(tokenBalance.owner, address)
                XCTAssertEqual(tokenBalance.token.supply, supply)
                XCTAssertEqual(tokenBalance.amount, 42)
                
                let secondTokenBalances = output[1]
                tokenBalance = try XCTUnwrap(secondTokenBalances.balance(ofToken: rri))
                XCTAssertEqual(tokenBalance.token.tokenDefinitionReference, rri)
                XCTAssertEqual(tokenBalance.owner, address)
                XCTAssertEqual(tokenBalance.token.supply, supply)
                XCTAssertEqual(tokenBalance.amount, 237)
        }
        )
    }
    
    
    func test_balance_of_two_tokens_in_same_tokenBalances() throws {
        
        let address = Address.irrelevant
        
        let rriFoo = ResourceIdentifier(address: address, name: "FOO")
        let tokenFoo = TokenDefinition(rri: rriFoo)
        let amountFoo: NonNegativeAmount = 5
        let supplyFoo: Supply = 100
        
        let rriBar = ResourceIdentifier(address: address, name: "BAR")
        let tokenBar = TokenDefinition(rri: rriBar)
        let amountBar: NonNegativeAmount = 42
        let supplyBar: Supply = 321
        
        try doTest(
            address: address,
            expectedNumberOfOutputs: 1,
            input: { balanceStateSubject, tokensStateSubject in
                balanceStateSubject.send([
                    rriFoo: TokenReferenceBalance(tokenResourceIdentifier: rriFoo, amount: amountFoo, owner: address),
                    rriBar: TokenReferenceBalance(tokenResourceIdentifier: rriBar, amount: amountBar, owner: address)
                ])
                
                tokensStateSubject.send([
                    rriFoo: TokenDefinitionsState.Value.full(TokenState(token: tokenFoo, supply: supplyFoo)),
                    rriBar: TokenDefinitionsState.Value.full(TokenState(token: tokenBar, supply: supplyBar))
                ])
            },
            
            assertCorrectnessOfOutput: { output in
                
                let tokenBalances = output[0]
                XCTAssertEqual(tokenBalances.balancePerToken.count, 2)

                let tokenBalanceFoo = try XCTUnwrap(tokenBalances.balance(ofToken: rriFoo))
                XCTAssertEqual(tokenBalanceFoo.token.tokenDefinitionReference, rriFoo)
                XCTAssertEqual(tokenBalanceFoo.owner, address)
                XCTAssertEqual(tokenBalanceFoo.token.supply, supplyFoo)
                XCTAssertEqual(tokenBalanceFoo.amount, amountFoo)
                
                let tokenBalanceBar = try XCTUnwrap(tokenBalances.balance(ofToken: rriBar))
                XCTAssertEqual(tokenBalanceBar.token.tokenDefinitionReference, rriBar)
                XCTAssertEqual(tokenBalanceBar.owner, address)
                XCTAssertEqual(tokenBalanceBar.token.supply, supplyBar)
                XCTAssertEqual(tokenBalanceBar.amount, amountBar)
        }
        )
    }
    
}

private extension TokenBalancesReducerTests {
    
    func doTestSingle(
        address: Address,
        
        line: UInt = #line,
        
        input: @escaping (
        _ balanceStateSubject: PassthroughSubject<TokenBalanceReferencesState, Never>,
        _ tokensStateSubject: PassthroughSubject<TokenDefinitionsState, Never>
        ) -> Void,
        
        assertCorrectnessOfOutput: @escaping (TokenBalance) -> Void
    ) throws {
        
        try doTest(
            address: address,
            expectedNumberOfOutputs: 1,
            line: line,
            input: input
        ) { (listOfTokenBalances: [TokenBalances]) in
            
            XCTAssertEqual(listOfTokenBalances.count, 1)
            let tokenBalances = listOfTokenBalances[0]
            XCTAssertEqual(tokenBalances.balancePerToken.count, 1)
            
            assertCorrectnessOfOutput(tokenBalances.balancePerToken.first!.value)
        }
        
    }
    
    func doTest(
        address: Address,
        expectedNumberOfOutputs: Int = 1,
        
        line: UInt = #line,
        
        input: (
        _ balanceStateSubject: PassthroughSubject<TokenBalanceReferencesState, Never>,
        _ tokensStateSubject: PassthroughSubject<TokenDefinitionsState, Never>
        ) -> Void,
        
        assertCorrectnessOfOutput: ([TokenBalances]) throws -> Void
    ) throws {
        let balanceStateSubject = PassthroughSubject<TokenBalanceReferencesState, Never>()
        let tokensStateSubject = PassthroughSubject<TokenDefinitionsState, Never>()
        
        let tokenBalancesReducer = TokenBalancesReducer(
            makeBalanceReferencesStatePublisher: { _ in balanceStateSubject.eraseToAnyPublisher() },
            makeTokenDefinitionsPublisher: { _ in tokensStateSubject.eraseToAnyPublisher() }
        )
        
        let tokenBalancesOfAddressPublisher = tokenBalancesReducer.tokenBalancesOfAddress(address)
        
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        var outputtedTokenBalances = [TokenBalances]()
        
        let cancellable = tokenBalancesOfAddressPublisher
            .prefix(expectedNumberOfOutputs)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { outputtedTokenBalances.append($0) }
        )
        
        input(balanceStateSubject, tokensStateSubject)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(outputtedTokenBalances.count, expectedNumberOfOutputs)
        
        try assertCorrectnessOfOutput(outputtedTokenBalances)
        
        XCTAssertNotNil(cancellable)
    }
}

extension TokenDefinition {
    
    init(
        rri: ResourceIdentifier,
        name: Name = .irrelevant,
        granularity: Granularity = .default,
        description: Description = .irrelevant,
        tokenSupplyType: SupplyType = .fixed,
        iconUrl: URL? = nil,
        tokenPermissions: TokenPermissions? = .default,
        supply: Supply? = nil
    ) {
        let symbol = try! Symbol(string: rri.name)
        
        self.init(
            symbol: symbol,
            tokenDefinedBy: rri.address,
            name: name,
            granularity: granularity,
            description: description,
            tokenSupplyType: tokenSupplyType,
            iconUrl: iconUrl,
            tokenPermissions: tokenPermissions,
            supply: supply
        )
    }
    
    init(
        symbol: Symbol,
        tokenDefinedBy: Address,
        name: Name = .irrelevant,
        granularity: Granularity = .default,
        description: Description = .irrelevant,
        tokenSupplyType: SupplyType = .fixed,
        iconUrl: URL? = nil,
        tokenPermissions: TokenPermissions? = .default,
        supply: Supply? = nil
    ) {
        self.init(
            symbol: symbol,
            name: name,
            tokenDefinedBy: tokenDefinedBy,
            granularity: granularity,
            description: description,
            tokenSupplyType: tokenSupplyType,
            iconUrl: iconUrl,
            tokenPermissions: tokenPermissions,
            supply: supply
        )
        
    }
}
