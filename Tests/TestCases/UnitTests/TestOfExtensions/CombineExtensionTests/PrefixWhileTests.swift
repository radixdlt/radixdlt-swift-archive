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
import XCTest
import Combine
@testable import RadixSDK

final class PrefixWhileTests: TestCase {
    
    // MARK: Combine's bundled
    func test_prefix_while_exclusive() {
        var returnValues = [Int]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let publisher = PassthroughSubject<Int, Never>()

        let cancellable = publisher
            .prefixWhile(behavior: .exclusive) { $0 < 3 }
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        publisher.send(1)
        publisher.send(2)
        publisher.send(3)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(returnValues, [1, 2])
        
        XCTAssertNotNil(cancellable)
        
    }
    
    // MARK: Behaviour.inclusive
    func test_prefix_while_inclusive() {
        var returnValues = [Int]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let publisher = PassthroughSubject<Int, Never>()
        
        let cancellable = publisher
            .prefixWhile(behavior: .inclusive) { $0 < 3 }
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        publisher.send(1)
        publisher.send(2)
        publisher.send(3)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(returnValues, [1, 2, 3])
        
        XCTAssertNotNil(cancellable)
        
    }
}
