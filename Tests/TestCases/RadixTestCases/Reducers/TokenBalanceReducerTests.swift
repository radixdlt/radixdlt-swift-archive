//
//  TokenBalanceReducerTests.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxTest
import RxBlocking
import RxSwift

class TokenBalanceReducerTests: XCTestCase {
    func testSimpleBalance() {
        let minted = mintedToken(10)
        let reducer = TokenBalanceReducer()
        let balances = reducer.reduce(minted)
        let balance = balances[xrd]
        XCTAssertEqual(balance?.amount.signedAmount, 10)
    }
    
    func testMultipleMintedTokens() {
        
        let spunConsumables: [SpunConsumable] = [
            mintedToken(3),
            mintedToken(5),
            mintedToken(11)
        ]
    
        let reducer = TokenBalanceReducer()
        let balances = reducer.reduce(spunConsumables: spunConsumables)

        guard let xrdBalance = balances[xrd] else { return XCTFail("Should not be nil") }
        XCTAssertEqual(xrdBalance.amount.signedAmount.magnitude, 19)
        XCTAssertLessThan(xrdBalance.amount.signedAmount.magnitude, 20)
        XCTAssertGreaterThan(xrdBalance.amount.signedAmount.magnitude, 18)
    }
}

private let address: Address = "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
private let xrd = TokenDefinitionReference(address: address, symbol: "XRD")

private func mintedToken(_ amount: Amount, spin: Spin = .up) -> SpunConsumable {
    return SpunConsumable(
        spin: spin,
        any: MintedTokenParticle(
            address: address,
            amount: amount,
            tokenDefinitionReference: xrd
        )
    )
}

private func transferredToken(_ amount: Amount, spin: Spin = .up) -> SpunConsumable {
    return SpunConsumable(
        spin: spin,
        any: TransferredTokenParticle(
            address: address,
            amount: amount,
            tokenDefinitionReference: xrd
        )
    )
}
