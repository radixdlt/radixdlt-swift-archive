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

final class PublisherFlatMapResultTests: TestCase {
    
    func test_flatMapResult_success_twice() {
        enum SomeError: Int, Swift.Error, Equatable {
            case foo
        }
        
        var returnValues = [Int]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let subjectOfResult = PassthroughSubject<Result<Int, SomeError>, Never>()
        
        let cancellable = subjectOfResult.flatMapResult()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        subjectOfResult.send(.success(1))
        subjectOfResult.send(.success(2))
        subjectOfResult.send(completion: .finished)
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(returnValues, [1, 2])
        
        XCTAssertNotNil(cancellable)
        
    }
    
    
    func test_flatMapResult_success_failure() {
        enum SomeError: Int, Swift.Error, Equatable {
            case foo
        }
        
        var returnValues = [Int]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let subjectOfResult = PassthroughSubject<Result<Int, SomeError>, Never>()
        
        let cancellable = subjectOfResult.flatMapResult()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        subjectOfResult.send(.success(1))
        subjectOfResult.send(.failure(SomeError.foo))
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(returnValues, [1])
        
        XCTAssertNotNil(cancellable)
        
    }
    
    func test_flatMapResult_success_completion_failure() {
        enum SomeError: Int, Swift.Error, Equatable {
            case foo
        }
        
        var returnValues = [Int]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let subjectOfResult = PassthroughSubject<Result<Int, SomeError>, SomeError>()
        
        let cancellable = subjectOfResult.flatMapResult()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { returnValues.append($0) }
        )
        
        subjectOfResult.send(.success(1))
        subjectOfResult.send(completion: .failure(SomeError.foo))
        
        wait(for: [expectation], timeout: 0.1)
        
        XCTAssertEqual(returnValues, [1])
        
        XCTAssertNotNil(cancellable)
        
    }
}
