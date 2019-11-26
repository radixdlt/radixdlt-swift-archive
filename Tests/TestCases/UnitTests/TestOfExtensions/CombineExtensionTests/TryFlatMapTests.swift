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

final class TryFlatMapTests: TestCase {
        

    func test_tryFlatMap_single_output_short() {
        doTest(
            produceOutput: { subject in
                subject.send(2)
                subject.send(completion: .finished)
            },
            
            expectedOutput: { values, errors in
                XCTAssertEqual(values.count, 1)
                XCTAssertTrue(errors.isEmpty)
            }
        )
    }
    
    func test_tryFlatMap_two_outputs() {
        doTest(
            produceOutput: { subject in
                subject.send(2)
                subject.send(4)
                subject.send(completion: .finished)
            },
            
            expectedOutput: { values, errors in
                XCTAssertEqual(values.count, 2)
                XCTAssertTrue(errors.isEmpty)
            }
        )
    }
    
    func test_tryFlatMap_single_error() {
        doTest(
            produceOutput: { subject in
                subject.send(1)
            },
            
            expectedOutput: { values, errors in
                XCTAssertTrue(values.isEmpty)
                XCTAssertEqual(errors.count, 1)
                XCTAssertEqual(errors[0], NumberError.notEven)
            }
        )
    }
    
    func test_tryFlatMap_single_error_then_single_output_produces_only_the_error() {
        doTest(
            produceOutput: { subject in
                subject.send(1)
                subject.send(2)
        },
            
            expectedOutput: { values, errors in
                XCTAssertTrue(values.isEmpty)
                XCTAssertEqual(errors.count, 1)
                XCTAssertEqual(errors[0], NumberError.notEven)
        }
        )
    }
    
    func test_tryFlatMap_single_output_then_error() {
        doTest(
            produceOutput: { subject in
                subject.send(2)
                subject.send(-2)
            },
            
            expectedOutput: { values, errors in
                XCTAssertEqual(values.count, 1)
                XCTAssertEqual(errors.count, 1)
                XCTAssertEqual(errors[0], NumberError.notPositive)
            }
        )
    }

    func test_tryFlatMap_two_outputs_then_error() {
        doTest(
            produceOutput: { subject in
                subject.send(2)
                subject.send(4)
                subject.send(-2)
        },
            
            expectedOutput: { values, errors in
                XCTAssertEqual(values.count, 2)
                XCTAssertEqual(errors.count, 1)
                XCTAssertEqual(errors[0], NumberError.notPositive)
            }
        )
    }
    
    func test_tryFlatMap_finish_with_no_output() {
        doTest(
            produceOutput: { subject in
                subject.send(completion: .finished)
            },
            
            expectedOutput: { values, errors in
                XCTAssertEqual(values.count, 0)
                XCTAssertEqual(errors.count, 0)
            }
        )
    }
}

private extension TryFlatMapTests {
    func doTest(
        produceOutput: (PassthroughSubject<Int, NumberError>) -> Void,
        expectedOutput: ((values: [Bool], errors: [NumberError])) -> Void
    ) {
       
        var returnValues = [Bool]()
        var returnErrors = [NumberError]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let positiveNumbersSubject = PassthroughSubject<Int, NumberError>()
        
        let positiveEvenNumberPublisher = positiveNumbersSubject.tryFlatMap { number -> AnyPublisher<Bool, NumberError> in
            if number <= 0 {
                throw NumberError.notPositive
            }
            if number % 2 != 0 {
                throw NumberError.notEven
            }
            return Just(true).setFailureType(to: NumberError.self).eraseToAnyPublisher()
        }
        
        let cancellable = positiveEvenNumberPublisher
            .sink(
                receiveCompletion: { completion in
                    defer { expectation.fulfill() }
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        returnErrors.append(error)
                    }
                },
                receiveValue: { returnValues.append($0) }
        )
        
        produceOutput(positiveNumbersSubject)
        
        wait(for: [expectation], timeout: 0.5)
        
        expectedOutput((values: returnValues, errors: returnErrors))
        
        XCTAssertNotNil(cancellable)
    }
    
    enum NumberError: Int, Swift.Error, Equatable {
        case notPositive
        case notEven
    }

}
