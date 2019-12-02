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

import Foundation
import Combine
@testable import RadixSDK
import XCTest

private let address: Address = .irrelevant

class InMemoryAtomStoreReducerTests: TestCase {

   
    func test_when_fetch_atoms_head_action_received__head_should_be_received_by_store() {
        let atomStore = InMemoryAtomStore()
        let reducer = InMemoryAtomStoreReducer(atomStore: atomStore)
        let node = makeNode()
        
        let uuid = UUID()
        
        let action = FetchAtomsActionObservation(
            address: address,
            node: node,
            atomObservation: .headNow(),
            uuid: uuid
        )
        
        let onSync = atomStore.onSync(address: address)
        
        let expectation = XCTestExpectation.init(description: self.description)
        
        var outputs = [Date]()
        
        let cancellable = onSync
            .first()
            .sink(
                receiveCompletion: { _ in expectation.fulfill()  },
                receiveValue: { outputs.append($0) }
            )
        
        reducer.reduce(action: action)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(outputs.count, 1)
        
        XCTAssertNotNil(cancellable)
        
    }
    
    
    func test_when_stored_action_received__a_soft_store_observation_should_be_stored() {
        let atomStore = InMemoryAtomStore()
        let reducer = InMemoryAtomStoreReducer(atomStore: atomStore)
        let node = makeNode()
        
        let uuid = UUID()
        
        let signedAtom: SignedAtom = .withDestinationAddress(address)
        let action = SubmitAtomActionStatus(
            atom: signedAtom,
            node: node,
            statusEvent: .stored,
            uuid: uuid
        )
        
        let publisher = atomStore.atomObservations(of: address)
        
        let expectation = XCTestExpectation(description: self.description)
        
        var outputs = [AtomObservation]()
        
        let cancellable = publisher
            .prefix(2)
            .sink(
                receiveCompletion: { _ in expectation.fulfill()  },
                receiveValue: { outputs.append($0) }
        )
        
        reducer.reduce(action: action)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(outputs.count, 2)
        let atomObservation0 = outputs[0]
        XCTAssertTrue(atomObservation0.isSoft)
        XCTAssertEqual(atomObservation0.atom, signedAtom.wrappedAtom.wrappedAtom)
        let atomObservation1 = outputs[1]
        XCTAssertTrue(atomObservation1.isHead)
        
        XCTAssertNotNil(cancellable)
        
    }

    func test_when_on_sync_is_called_many_times_using_same_address_only_one_date_is_outputted() {
        let atomStore = InMemoryAtomStore()
        let reducer = InMemoryAtomStoreReducer(atomStore: atomStore)
        let node = makeNode()
        
        let uuid = UUID()
        
        let action = FetchAtomsActionObservation(
            address: address,
            node: node,
            atomObservation: .headNow(),
            uuid: uuid
        )
        
        var expectations = [XCTestExpectation]()
        var outputs = Set<Date>()

        let times = 10
        var cancellables = Set<AnyCancellable>()
        for _ in 0..<times {
            let expectation = XCTestExpectation.init(description: self.description)
           atomStore.onSync(address: address)
                .first()
                .sink(
                    receiveCompletion: { _ in expectation.fulfill()  },
                    receiveValue: { outputs.insert($0) }
            ).store(in: &cancellables)
            expectations.append(expectation)
        }
        
        reducer.reduce(action: action)
        XCTAssertEqual(expectations.count, times)
        XCTAssertEqual(cancellables.count, times)
        wait(for: expectations, timeout: 0.1)
        
        XCTAssertEqual(outputs.count, 1)
    }

}
