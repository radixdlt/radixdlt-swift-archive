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
        let reducer = TokenBalanceReducer()
        let balances = reducer.reduce(transferrable(10))
        
        let balance = balances[xrd]
        XCTAssertEqual(balance?.amount, 10)
    }
    
    func testMultipleMintedTokens() {
        
        let spunTransferrable: [SpunTransferrable] = [
            transferrable(3),
            transferrable(5),
            transferrable(11)
        ]
    
        let reducer = TokenBalanceReducer()
        let balances = reducer.reduce(spunTransferrable: spunTransferrable)

        guard let xrdBalance = balances[xrd] else { return XCTFail("Should not be nil") }
        XCTAssertEqual(xrdBalance.amount, 19)
        XCTAssertLessThan(xrdBalance.amount, 20)
        XCTAssertGreaterThan(xrdBalance.amount, 18)
    }
}

private let address: Address = "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
private let xrd = ResourceIdentifier(address: address, name: "XRD")


private func transferrable(_ amount: PositiveAmount, spin: Spin = .up) -> SpunTransferrable {
    return SpunTransferrable(
        spin: spin,
        particle: TransferrableTokensParticle(
            amount: amount,
            address: address,
            tokenDefinitionReference: xrd
        )
    )
}
