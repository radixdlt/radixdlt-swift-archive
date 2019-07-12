//
//  TokenDefinitionsStateReducerTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-07-10.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class TokenDefinitionsStateReducerTests: XCTestCase {

    func testTokenWithNoMint() {
        let tokenDefinitionParticle = makeTokenDefinitionParticle(tokenPermissions: [.mint: .tokenCreationOnly])
        
        let expectedRri = tokenDefinitionParticle.identifier
        let reducer = TokenDefinitionsReducer()
        let state = reducer.reduce(state: .init(), particle: tokenDefinitionParticle)
        XCTAssertNil(state.tokenState(identifier: expectedRri), "No supply info yet, cannot make state")
        guard let tokenDefinition = state.tokenDefinition(identifier: expectedRri) else { return XCTFail("expected TokenDefintion") }
        
        assertValuesIn(tokenDefinition: tokenDefinition)
    }

    func testTokenWithMint() {
        let tokenDefinitionParticle = makeTokenDefinitionParticle(tokenPermissions: [.mint: .tokenOwnerOnly])
        
        let expecteRri = tokenDefinitionParticle.identifier
        
        let hundred: PositiveAmount = 100
        
        let unallocatedTokensParticle = UnallocatedTokensParticle(
            amount: PositiveAmount.maxValue256Bits - hundred,
            tokenDefinitionReference: expecteRri
        )
        
        print(try! RadixJSONEncoder().encode(unallocatedTokensParticle).toString())
        
        let reducer = TokenDefinitionsReducer()
        let state_Un = reducer.reduce(state: .init(), particle: unallocatedTokensParticle)
        let state_Un_Td = reducer.reduce(state: state_Un, particle: tokenDefinitionParticle)
        
        XCTAssertEqual(state_Un_Td.tokenState(identifier: expecteRri)?.totalSupply, 100)
        XCTAssertEqual(state_Un_Td.tokenState(identifier: expecteRri)?.tokenSupplyType, .mutable)

        // Assert that no action is performed on `TransferrableTokensParticle`. Is this really correct?
        let transferrableTokensParticle = TransferrableTokensParticle(token: tokenDefinitionParticle, amount: .irrelevant)
        XCTAssertEqual(state_Un, reducer.reduce(state: state_Un, particle: transferrableTokensParticle))
        
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
