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
import Combine
@testable import RadixSDK

class DefaultAtomToTransactionMapperCreateTokenFromGenesisAtomTests: TestCase {
    
    private let alice = AbstractIdentity()
    
    func testTransactionWithSingleCreateTokenActionWithoutInitialSupply() {
        let mapper = DefaultAtomToTransactionMapper(identity: alice)
        
        let atom = UniverseConfig.localnet.genesis.atoms[0]
        let expectation = XCTestExpectation(description: self.debugDescription)
        var transactions = [ExecutedTransaction]()
        let cancellable = mapper.transactionFromAtom(atom)
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { transactions.append($0) }
        )
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(transactions.count, 1)
        let transaction = transactions[0]
        let actions = transaction.actions
        XCTAssertEqual(actions.count, 2)
        
        let sendMessageAction: SendMessageAction! = XCTAssertType(of: actions[0])
        XCTAssertEqual(sendMessageAction!.sender, "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor")
        XCTAssertEqual(sendMessageAction!.textMessage(), "Radix... just imagine!")
        
        let createTokenAction: CreateTokenAction! = XCTAssertType(of: actions[1])
        XCTAssertEqual(createTokenAction.symbol, "XRD")
        XCTAssertEqual(createTokenAction.tokenSupplyType, .fixed)
        
        XCTAssertNotNil(cancellable)
    }
    
}
