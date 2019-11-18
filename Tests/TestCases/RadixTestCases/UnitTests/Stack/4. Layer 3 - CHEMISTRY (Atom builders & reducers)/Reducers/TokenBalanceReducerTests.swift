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

class TokenBalanceReducerTests: TestCase {
    
    func testSimpleBalance() {
        let reducer = TokenBalanceReferencesReducer()
        let balances = try! reducer.reduceFromInitialState(upParticles: [transferrable(10)])
        
        let balance = balances[xrd]
        XCTAssertEqual(balance?.amount, 10)
    }
    
    func testMultipleMintedTokens() {
        let reducer = TokenBalanceReferencesReducer()
    
        let balances = try! reducer.reduceFromInitialState(upParticles: [
            transferrable(3),
            transferrable(5),
            transferrable(11)
            ])

        guard let xrdBalance = balances[xrd] else { return XCTFail("Should not be nil") }
        XCTAssertEqual(xrdBalance.amount, 19)
    }
}

private let address: Address = "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
private let xrd = ResourceIdentifier(address: address, name: "XRD")


/// Assumes spin up
private func transferrable(_ amount: PositiveAmount) -> AnyUpParticle {
    let particle = try! TransferrableTokensParticle(
        amount: amount,
        address: address,
        tokenDefinitionReference: xrd
    )
    return AnyUpParticle(particle: particle)
}
