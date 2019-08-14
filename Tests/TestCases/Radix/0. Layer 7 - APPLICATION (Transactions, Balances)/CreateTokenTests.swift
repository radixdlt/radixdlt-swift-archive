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
import RxSwift
import RxTest

class CreateTokenTests: LocalhostNodeTest {

    private let aliceIdentity = AbstractIdentity(alias: "Alice")
    private let bobAccount = Account()
    private let claraAccount = Account()
    private let dianaAccount = Account()
    
    private lazy var application = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: aliceIdentity)
    
    private lazy var alice = application.addressOfActiveAccount
    private lazy var bob = application.addressOf(account: bobAccount)
    private lazy var clara = application.addressOf(account: claraAccount)
    private lazy var diana = application.addressOf(account: dianaAccount)
    
    private let disposeBag = DisposeBag()
    
    
    func testFailingCreateTokenInSomeoneElsesName() {

        let tokenCreation = application.create(token: createTokenAction(creator: bob))
        
        tokenCreation.blockingAssertThrows(
            error: CreateTokenError.uniqueActionError(.nonMatchingAddress(activeAddress: alice, butActionStatesAddress: bob))
        )
    }
    
    func testFailCreatingTokenWithSameRRIAsUniqueId() {
        
        let createToken = createTokenAction(symbol: "FOO")
        let rri = createToken.identifier
        
        let transaction = Transaction {[
            PutUniqueIdAction(uniqueMaker: alice, string: "FOO"),
            createToken
        ]}
        
        let tokenCreation = application.send(transaction: transaction)
        
        tokenCreation.blockingAssertThrows(
            error: CreateTokenError.uniqueActionError(.rriAlreadyUsedByUniqueId(string: rri.name))
        )
    }
    
    func testFailCreatingTokenWithSameRRIAsExistingMutableSupplyToken() {
        
        let createMutableSupplyTokenAction = createTokenAction()
        let rri = createMutableSupplyTokenAction.identifier
        
        let transaction = Transaction {[
            createMutableSupplyTokenAction,
            createTokenAction(),
        ]}
        
        let resultOfUniqueMaking = application.send(transaction: transaction)
        
        resultOfUniqueMaking.blockingAssertThrows(
            error: CreateTokenError.uniqueActionError(.rriAlreadyUsedByMutableSupplyToken(identifier: rri))
        )
    }
    
    func testFailCreatingTokenWithSameRRIAsExistingFixedSupplyToken() {
        
        let createFixedSupplyTokenAction = createTokenAction(supply: .fixed(to: 123))
        let rri = createFixedSupplyTokenAction.identifier
        
        let transaction = Transaction {[
            createFixedSupplyTokenAction,
            createTokenAction(),
        ]}
        
        let resultOfUniqueMaking = application.send(transaction: transaction)
        
        resultOfUniqueMaking.blockingAssertThrows(
            error: CreateTokenError.uniqueActionError(.rriAlreadyUsedByFixedSupplyToken(identifier: rri))
        )
    }
    
}

private extension CreateTokenTests {
    func createTokenAction(
        symbol: Symbol = "FOO",
        supply: CreateTokenAction.InitialSupply.SupplyTypeDefinition = .mutableZeroSupply,
        creator: Address? = nil
    ) -> CreateTokenAction {
        
        let creatorAddress = creator ?? alice

        return try! CreateTokenAction(
            creator: creatorAddress,
            name: .irrelevant,
            symbol: symbol,
            description: .irrelevant,
            defineSupply: supply
        )
        
    }
}
