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

private extension Supply {
    static let hundred: Supply = 10
}

class TokenDefinitionsStateReducerTests: TestCase {

    func testTokenWithNoMint() {
        let tokenDefinitionParticle = makeMutableSupplyTokenDefinitionParticle(tokenPermissions: [.mint: .all])
        
        let expectedRri = tokenDefinitionParticle.tokenDefinitionReference
        let reducer = TokenDefinitionsReducer()
        let state = try! reducer.reduce(state: .init(), upParticle: AnyUpParticle(particle: tokenDefinitionParticle))
        XCTAssertNil(state.tokenState(identifier: expectedRri), "No supply info yet, cannot make state")
        guard let tokenDefinition = state.tokenDefinition(identifier: expectedRri) else { return XCTFail("expected TokenDefintion") }
        
        assertValuesIn(tokenDefinition: tokenDefinition, expectedTokenSupplyType: .mutable)
    }
    
    func testFixedTokenWithNoMint() {
        let tokenDefinitionParticle = makeFixedSupplyTokenDefinitionParticle(supply: 1)
        
        let expectedRri = tokenDefinitionParticle.tokenDefinitionReference
        let reducer = TokenDefinitionsReducer()
        let state = try! reducer.reduce(state: .init(), upParticle: AnyUpParticle(particle: tokenDefinitionParticle))
        XCTAssertNil(state.tokenState(identifier: expectedRri), "No supply info yet, cannot make state")
        guard let tokenDefinition = state.tokenDefinition(identifier: expectedRri) else { return XCTFail("expected TokenDefintion") }
        
        assertValuesIn(tokenDefinition: tokenDefinition, expectedTokenSupplyType: .fixed)
    }

    func testTokenWithMint() {
        let tokenDefinitionParticle = makeMutableSupplyTokenDefinitionParticle(tokenPermissions: [.mint: .tokenOwnerOnly])
        
        let expectedRri = tokenDefinitionParticle.tokenDefinitionReference
        
        let unallocatedTokensParticle = UnallocatedTokensParticle(
            amount: try! Supply(subtractedFromMax: Supply.hundred),
            tokenDefinitionReference: expectedRri
        )
        
        print(try! RadixJSONEncoder().encode(unallocatedTokensParticle).toString())
        
        let reducer = TokenDefinitionsReducer()
        let state_Un = try! reducer.reduce(state: .init(), upParticle: AnyUpParticle(particle: unallocatedTokensParticle))
        let state_Un_Td = try! reducer.reduce(state: state_Un, upParticle: AnyUpParticle(particle: tokenDefinitionParticle))
        
        XCTAssertEqual(state_Un_Td.tokenState(identifier: expectedRri)?.totalSupply, Supply.hundred)
        XCTAssertEqual(state_Un_Td.tokenState(identifier: expectedRri)?.tokenSupplyType, .mutable)

        // Assert that no action is performed on `TransferrableTokensParticle`.
        let transferrableTokensParticle = try! TransferrableTokensParticle(mutableSupplyToken: tokenDefinitionParticle, amount: .irrelevant)
        XCTAssertEqual(state_Un, try! reducer.reduce(state: state_Un, upParticle: AnyUpParticle(particle: transferrableTokensParticle)))
        
    }

}

private extension TokenDefinitionsStateReducerTests {
    func assertValuesIn(tokenDefinition: TokenDefinition, expectedTokenSupplyType: SupplyType) {
        XCTAssertEqual(tokenDefinition.tokenSupplyType, expectedTokenSupplyType)
        XCTAssertEqual(tokenDefinition.symbol, "TEST")
        XCTAssertEqual(tokenDefinition.name, "Test")
        XCTAssertEqual(tokenDefinition.tokenDefinedBy, "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor")
        XCTAssertEqual(tokenDefinition.granularity, .default)
        XCTAssertEqual(tokenDefinition.description, "Testing Testing")
    }
}

private extension TransferrableTokensParticle {
    init(
        mutableSupplyToken token: MutableSupplyTokenDefinitionParticle,
        amount: PositiveAmount) throws {
        try self.init(
            amount: amount,
            address: token.address,
            tokenDefinitionReference: token.tokenDefinitionReference,
            permissions: token.permissions,
            granularity: token.granularity
        )
    }
}

private func makeMutableSupplyTokenDefinitionParticle(tokenPermissions: TokenPermissions) -> MutableSupplyTokenDefinitionParticle {
    return try! MutableSupplyTokenDefinitionParticle(
        symbol: "TEST",
        name: "Test",
        description: "Testing Testing",
        address: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
        granularity: .default,
        permissions: tokenPermissions
    )
}

private func makeFixedSupplyTokenDefinitionParticle(supply: PositiveSupply) -> FixedSupplyTokenDefinitionParticle {
    return FixedSupplyTokenDefinitionParticle(
        symbol: "TEST",
        name: "Test",
        description: "Testing Testing",
        address: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
        supply: supply,
        granularity: .default
    )
}
