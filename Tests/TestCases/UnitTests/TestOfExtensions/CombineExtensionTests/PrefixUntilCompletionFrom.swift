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

final class PrefixUntilCompletionFromTests: TestCase {
    
    // MARK: Combine's bundled
    func test_that_publisher___prefix_untilOutputFrom___completes_when_received_output() {
        
        let finishTriggeringSubject = PassthroughSubject<Void, Never>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send()
        }
        ) {
            return $0.merge(with: $1).prefix(untilOutputFrom: finishTriggeringSubject).eraseToAnyPublisher()
        }
        
    }
    
    // MARK: Custom `prefix(until*`
    
    // MARK: `prefix:untilCompletionFrom`
    func test_that_publisher___prefix_untilCompletionFrom___completes_when_received_finish() {
        
        let finishTriggeringSubject = PassthroughSubject<Int, Never>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send(completion: .finished)
        }
        ) {
            $0.merge(with: $1).prefix(untilCompletionFrom: finishTriggeringSubject)
        }
    }
    
    // MARK: `prefix:untilOutputOrFinishFrom`
    func test_that_publisher___prefix_untilOutputOrFinishFrom___completes_when_received_finish() {
        
        let finishTriggeringSubject = PassthroughSubject<Int, Never>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send(completion: .finished)
        }
        ) {
            $0.merge(with: $1).prefix(untilOutputOrFinishFrom: finishTriggeringSubject)
        }
    }
    
    
    func test_that_publisher___prefix_untilOutputOrFinishFrom___completes_when_received_output() {
        
        let finishTriggeringSubject = PassthroughSubject<Void, Never>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send()
        }
        ) {
            $0.merge(with: $1).prefix(untilOutputOrFinishFrom: finishTriggeringSubject)
        }
    }
    
    // MARK: `prefix:untilOutputOrCompletionFrom`
    func test_that_publisher___prefix_untilOutputOrCompletionFrom___completes_when_received_finish() {
        
        let finishTriggeringSubject = PassthroughSubject<Int, Never>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send(completion: .finished)
        }
        ) {
            $0.merge(with: $1).prefix(untilOutputOrCompletionFrom: finishTriggeringSubject)
        }
    }
    
    
    func test_that_publisher___prefix_untilOutputOrCompletionFrom___completes_when_received_output() {
        
        let finishTriggeringSubject = PassthroughSubject<Void, Never>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send()
        }
        ) {
            $0.merge(with: $1).prefix(untilOutputOrCompletionFrom: finishTriggeringSubject)
        }
    }
    
    func test_that_publisher___prefix_untilOutputOrCompletionFrom___completes_when_received_failure() {
        struct ErrorMarker: Swift.Error {}
        let finishTriggeringSubject = PassthroughSubject<Void, ErrorMarker>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send(completion: .failure(ErrorMarker()))
        }
        ) {
            $0.merge(with: $1).prefix(untilOutputOrCompletionFrom: finishTriggeringSubject)
        }
    }
    
    // MARK: `prefix:untilFailureFrom`
    func test_that_publisher___prefix_untilFailureFrom___completes_when_received_output() {
        struct ErrorMarker: Swift.Error {}
        let finishTriggeringSubject = PassthroughSubject<Void, ErrorMarker>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send(completion: .failure(ErrorMarker()))
        }
        ) {
            $0.merge(with: $1).prefix(untilFailureFrom: finishTriggeringSubject)
        }
    }

    // MARK: `prefix:untilEventFrom`
    func test_that_publisher___prefix_untilEventFrom___outut_completes_when_received_output() {
        
        let finishTriggeringSubject = PassthroughSubject<Void, Never>()
        
        doTestPublisherCompletes(
            triggerFinish: {
                finishTriggeringSubject.send()
        }
        ) {
            $0.merge(with: $1).prefix(untilEventFrom: finishTriggeringSubject, completionTriggerOptions: [.output])
        }
    }
    
    func doTestPublisherCompletes(
        _ line: UInt = #line,
        
        triggerFinish: () -> Void,
        
        makePublisherToTest: (
        _ first: AnyPublisher<Int, Never>,
        _ second: AnyPublisher<Int, Never>
        ) -> AnyPublisher<Int, Never>
    ) {
        
        let first = PassthroughSubject<Int, Never>()
        let second = PassthroughSubject<Int, Never>()
        
        let publisherToTest = makePublisherToTest(
            first.eraseToAnyPublisher(),
            second.eraseToAnyPublisher()
        )
        
        var returnValues = [Int]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let cancellable = publisherToTest
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        first.send(1)
        first.send(2)
        first.send(completion: .finished)
        first.send(3)
        second.send(4)
        triggerFinish()
        second.send(5)
        
        wait(for: [expectation], timeout: 0.1)
        
        // output `3` sent by subject `first` is ignored, since it's sent after it has completed.
        // output `5` sent by subject `second` is ignored since it's sent after our `publisherToTest` has completed
        XCTAssertEqual(returnValues, [1, 2, 4], line: line)
        
        XCTAssertNotNil(cancellable, line: line)
    }
    
    
}
