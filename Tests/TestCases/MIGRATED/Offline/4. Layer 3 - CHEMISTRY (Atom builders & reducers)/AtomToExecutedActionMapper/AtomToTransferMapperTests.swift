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

class AtomToTransferMapperTests: TestCase {
    
    private let alice: Address = .irrelevant(index: 1)
    private let bob: Address = .irrelevant(index: 2)
    
    func testAtomToTransferWithReturn() throws {
        
        let createAliceToken = try CreateTokenAction.new(creator: alice, supply: .fixed(to: 100))
        let aliceCoin = createAliceToken.identifier
        
        let transactionToAtomMapper = DefaultTransactionToAtomMapper(atomStore:
            HardCodedAtomStore.particlesFrom(
                transaction: Transaction { createAliceToken },
                address: alice
            )
        )
        
        let tokenTransferAction = TransferTokensAction(from: alice, to: bob, amount: 14, tokenResourceIdentifier: aliceCoin, attachment: "Taxi".toData())
        
        let atom = try transactionToAtomMapper.atomFrom(
            transaction: Transaction { tokenTransferAction },
            addressOfActiveAccount: alice
        )
        
        let atomToTransferMapper = DefaultAtomToTokenTransferMapper()
        let actionsPublisher = atomToTransferMapper.mapAtomToActions(atom)

        let transfer = try actionsPublisher.toBlockingGetFirst()

        XCTAssertEqual(transfer.amount, 14)
        XCTAssertEqual(transfer.attachedMessage(), "Taxi")
        XCTAssertEqual(transfer.sender, alice)
        XCTAssertEqual(transfer.recipient, bob)
        
    }
    
    func testAtomToTransferWithoutReturn() throws {
        
        let createAliceToken = try CreateTokenAction.new(creator: alice, supply: .fixed(to: 100))
        let aliceCoin = createAliceToken.identifier
        
        let transactionToAtomMapper = DefaultTransactionToAtomMapper(atomStore:
            HardCodedAtomStore.particlesFrom(
                transaction: Transaction { createAliceToken },
                address: alice
            )
        )
        
        let tokenTransferAction = TransferTokensAction(from: alice, to: bob, amount: 100, tokenResourceIdentifier: aliceCoin, attachment: "Taxi".toData())
        
        let atom = try transactionToAtomMapper.atomFrom(
            transaction: Transaction { tokenTransferAction },
            addressOfActiveAccount: alice
        )
        
        let atomToTransferMapper = DefaultAtomToTokenTransferMapper()
        
        let actionsPublisher = atomToTransferMapper.mapAtomToActions(atom)
        let transfer = try actionsPublisher.toBlockingGetFirst()
        
        XCTAssertEqual(transfer.amount, 100)
        XCTAssertEqual(transfer.attachedMessage(), "Taxi")
        XCTAssertEqual(transfer.sender, alice)
        XCTAssertEqual(transfer.recipient, bob)
    }
}
