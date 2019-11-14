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

import Foundation
import Combine
@testable import RadixSDK
import XCTest

final class AtomPullerTests: TestCase {

    private let address1: Address = .irrelevant(index: 1)
    private let address2: Address = .irrelevant(index: 2)
    private let address3: Address = .irrelevant(index: 3)
    
    func test_DefaultAtomPuller() throws {
        
        var dispatchedNodeActions = [NodeAction]()
        let requestCache: DefaultAtomPuller.RequestCache = [:]
        
        let atomPuller: AtomPuller = DefaultAtomPuller(
            requestCache: requestCache,
            nodeActionsDispatcher: .callback { dispatchedNodeActions.append($0) }
        )
  
        XCTAssertTrue(requestCache.isEmpty)
        let cancellable = atomPuller.pull(address: address1)
        XCTAssertFalse(requestCache.isEmpty)
        XCTAssertNil(requestCache.valueFor(key: address2))

        XCTAssertEqual(dispatchedNodeActions.count, 1)
        let fetchAtomsActionRequest: FetchAtomsActionRequest! = XCTAssertType(of: dispatchedNodeActions[0])
        cancellable.cancel()
        XCTAssertEqual(dispatchedNodeActions.count, 2)
        let fetchAtomsActionCancel: FetchAtomsActionCancel! = XCTAssertType(of: dispatchedNodeActions[1])
        XCTAssertEqual(fetchAtomsActionRequest.address, address1)
        XCTAssertEqual(fetchAtomsActionCancel.uuid, fetchAtomsActionRequest.uuid)
        XCTAssertEqual(fetchAtomsActionCancel.address, address1)
    }
    
}

extension NodeActionsDispatcher {
    static func callback(_ dispatchCalledHandler: @escaping (NodeAction) -> Void) -> Self {
        Self {
            dispatchCalledHandler($0)
        }
    }
}
