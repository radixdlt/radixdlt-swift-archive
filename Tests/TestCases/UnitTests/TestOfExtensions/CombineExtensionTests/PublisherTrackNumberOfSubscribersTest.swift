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

final class PublisherTrackNumberOfSubscribersTest: TestCase {
    
    func test_four_subscribers_complete_by_finish() {
        doTest { publisher in
            publisher.send(completion: .finished)
        }
    }
    
    func test_four_subscribers_complete_by_error() {
        doTest { publisher in
            publisher.send(completion: .failure(.init()))
        }
    }
    
}

private extension PublisherTrackNumberOfSubscribersTest {
    struct EmptyError: Swift.Error {}
    func doTest(_ line: UInt = #line, complete: (PassthroughSubject<Int, EmptyError>) -> Void) {
        let publisher = PassthroughSubject<Int, EmptyError>()
        
        var numberOfSubscriptions = 0
        let trackable = publisher.trackNumberOfSubscribers { update in
            switch update {
            case .increased: numberOfSubscriptions += 1
            case .decreased: numberOfSubscriptions -= 1
            }
            
        }
        
        XCTAssertEqual(numberOfSubscriptions, 0, line: line)
        
        func subscribe() -> Cancellable {
            return trackable.sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        }
        
        let cancellable1 = subscribe()
        let cancellable2 = subscribe()
        let cancellable3 = subscribe()
        let cancellable4 = subscribe()
        
        XCTAssertNotNil(cancellable1, line: line)
        XCTAssertNotNil(cancellable2, line: line)
        XCTAssertNotNil(cancellable3, line: line)
        XCTAssertNotNil(cancellable4, line: line)
        XCTAssertEqual(numberOfSubscriptions, 4, line: line)
        
        cancellable1.cancel()
        XCTAssertEqual(numberOfSubscriptions, 3, line: line)
        
        cancellable2.cancel()
        XCTAssertEqual(numberOfSubscriptions, 2, line: line)
        
        complete(publisher)
        XCTAssertEqual(numberOfSubscriptions, 0, line: line)
    }
}
