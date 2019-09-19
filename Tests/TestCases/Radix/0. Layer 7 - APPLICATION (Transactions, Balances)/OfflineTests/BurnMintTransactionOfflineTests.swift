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

class BurnMintTransactionOfflineTests: XCTestCase {


    func testBurnMintMultipleTimes() {
        let alice = Address.irrelevant

        let createTokenAction = try! CreateTokenAction(
            creator: alice,
            name: .irrelevant,
            symbol: .irrelevant,
            description: .irrelevant,
            supply: .mutableZeroSupply
        )

        let rri = createTokenAction.identifier

        let createTokenActionToParticleGroupsMapper = DefaultCreateTokenActionToParticleGroupsMapper()

        let createTokenParticleGroups = try! createTokenActionToParticleGroupsMapper.particleGroups(
            for: createTokenAction,
            upParticles: [],
            addressOfActiveAccount: alice
        )

        let atomStore = HardCodedAtomStore(upParticles: createTokenParticleGroups.upParticles())

        let transaction = Transaction(TokenContext(rri: rri, actor: alice)) {
            Mint(amount: 100)   // 100
            Burn(amount: 3)     // 97
            Mint(amount: 5)     // 102
            Burn(amount: 7)     // 95
            Mint(amount: 13)    // 108
            Burn(amount: 17)    // 91
        }

        let transactionToAtomMapper = DefaultTransactionToAtomMapper(atomStore: atomStore)

        let atom = try! transactionToAtomMapper.atomFrom(transaction: transaction, addressOfActiveAccount: alice)

        let upParticles = atom.upParticles()

        let tokenStateReducer = TokenDefinitionsReducer()

        let tokenState = try! tokenStateReducer.reduceFromInitialState(upParticles: upParticles)
        XCTAssertEqual(tokenState.tokenState(identifier: rri)!.totalSupply, 91)
    }

}
