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

class DefaultAtomToTransactionMapperMessageAndPutUniqueActionTests: TestCase {
    
    private let aliceIdentity = AbstractIdentity()
    private lazy var alice: Address = aliceIdentity.snapshotActiveAccount.addressFromMagic(.irrelevant)
    private let bob = Address.irrelevant(index: 2)
  
    func testUniqueIdAndMessagePArticle() {
        let mapper = DefaultAtomToTransactionMapper(identity: aliceIdentity)
      
        let uniqueParticle = UniqueParticle(address: alice, string: "FOO")
        let rriParticle = ResourceIdentifierParticle(resourceIdentifier: uniqueParticle.identifier)
        
        let atom = Atom(metaData: .timeNow, particleGroups: [
            
            ParticleGroup([
                rriParticle.withSpin(.down),
                uniqueParticle.withSpin(.up)
            ]),
            
            ParticleGroup([
                MessageParticle(from: alice, to: bob, message: "Hey Bob!").withSpin(.up)
            ])
        ])
        
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
        XCTAssertEqual(transaction.actions.count, 2)
        XCTAssertNotNil(cancellable)
    }
    
}
