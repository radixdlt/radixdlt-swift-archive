/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import XCTest
@testable import RadixSDK

class TokenDefinitionsStateReducerTests: XCTestCase {

    func testTokenWithNoMint() {
        let tokenDefinitionParticle = makeTokenDefinitionParticle(tokenPermissions: [.mint: .tokenCreationOnly])
        
        let expectedRri = tokenDefinitionParticle.identifier
        let reducer = TokenDefinitionsReducer()
        let state = reducer.reduce(state: .init(), upParticle: AnyUpParticle(particle: tokenDefinitionParticle))
        XCTAssertNil(state.tokenState(identifier: expectedRri), "No supply info yet, cannot make state")
        guard let tokenDefinition = state.tokenDefinition(identifier: expectedRri) else { return XCTFail("expected TokenDefintion") }
        
        assertValuesIn(tokenDefinition: tokenDefinition)
    }

    func testTokenWithMint() {
        let tokenDefinitionParticle = makeTokenDefinitionParticle(tokenPermissions: [.mint: .tokenOwnerOnly])
        
        let expecteRri = tokenDefinitionParticle.identifier
        
        let hundred: PositiveAmount = 100
        
        let unallocatedTokensParticle = UnallocatedTokensParticle(
            amount: try! Supply(subtractingFromMax: hundred),
            tokenDefinitionReference: expecteRri
        )
        
        print(try! RadixJSONEncoder().encode(unallocatedTokensParticle).toString())
        
        let reducer = TokenDefinitionsReducer()
        let state_Un = reducer.reduce(state: .init(), upParticle: AnyUpParticle(particle: unallocatedTokensParticle))
        let state_Un_Td = reducer.reduce(state: state_Un, upParticle: AnyUpParticle(particle: tokenDefinitionParticle))
        
        XCTAssertEqual(state_Un_Td.tokenState(identifier: expecteRri)?.totalSupply, 100)
        XCTAssertEqual(state_Un_Td.tokenState(identifier: expecteRri)?.tokenSupplyType, .mutable)

        // Assert that no action is performed on `TransferrableTokensParticle`. Is this really correct?
        let transferrableTokensParticle = TransferrableTokensParticle(token: tokenDefinitionParticle, amount: .irrelevant)
        XCTAssertEqual(state_Un, reducer.reduce(state: state_Un, upParticle: AnyUpParticle(particle: transferrableTokensParticle)))
        
    }

}

private extension TokenDefinitionsStateReducerTests {
    func assertValuesIn(tokenDefinition: TokenDefinition) {
        XCTAssertEqual(tokenDefinition.tokenSupplyType, .fixed)
        XCTAssertEqual(tokenDefinition.symbol, "TEST")
        XCTAssertEqual(tokenDefinition.name, "Test")
        XCTAssertEqual(tokenDefinition.tokenDefinedBy, "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor")
        XCTAssertEqual(tokenDefinition.granularity, .default)
        XCTAssertEqual(tokenDefinition.description, "Testing Testing")
    }
}

private func makeTokenDefinitionParticle(tokenPermissions: TokenPermissions) -> TokenDefinitionParticle {
    return TokenDefinitionParticle(
        symbol: "TEST",
        name: "Test",
        description: "Testing Testing",
        address: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
        granularity: .default,
        permissions: tokenPermissions
    )
}

private extension NonNegativeAmount {
    static var irrelevant: NonNegativeAmount { return 42 }
}
