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
@testable import RadixSDK
import XCTest
import Combine

struct IntDivisibleByFiveFlow {
    
    func randomInteger(in range: Range<Int>) -> AnyPublisher<Int, Never> {
        return Just(Int.random(in: range))
            .eraseToAnyPublisher()
    }
    
    func filterOdd<P>(_ publisher: P) -> AnyPublisher<Int, Never>
        where P: Publisher, P.Output == Int, P.Failure == Never
    {
        publisher.filter { !$0.isMultiple(of: 2) }
            .eraseToAnyPublisher()
    }
    
    func filterMultipleOfThree<P>(_ publisher: P) -> AnyPublisher<Int, Never>
        where P: Publisher, P.Output == Int, P.Failure == Never
    {
        publisher.filter { $0.isMultiple(of: 3) }
            .eraseToAnyPublisher()
    }
    
    func mapIsDivisibleByFiveString<P>(_ publisher: P) -> AnyPublisher<String, Never>
        where P: Publisher, P.Output == Int, P.Failure == Never
    {
        publisher.map {
            if $0.isMultiple(of: 5) {
                return "5∣\($0)"
            } else {
                return "5∤\($0)"
            }
        }.eraseToAnyPublisher()
    }
    
    
    func start<P>(with integers: P) -> AnyPublisher<String, Never> where P: Publisher, P.Output == Int, P.Failure == Never {
        integers
            |> filterOdd
            |> filterMultipleOfThree
            |> mapIsDivisibleByFiveString
    }
}


final class PublisherPipeOperatorTests: XCTestCase {
    
    func testIntDivisibleByFiveFlow() {
        var returnValues = [String]()
        let expectation = XCTestExpectation(description: self.debugDescription)
        
        let flow = IntDivisibleByFiveFlow()
        let intSubject = PassthroughSubject<Int, Never>()
        let cancellable = flow.start(with: intSubject)
            .sink(
                receiveCompletion: { completion in
                    expectation.fulfill()
            },
                receiveValue: { value in returnValues.append(value) }
        )
        
        
        for int in 0..<22 {
            intSubject.send(int)
        }
        intSubject.send(completion: .finished)
        wait(for: [expectation], timeout: 0.01)
        
        XCTAssertEqual(returnValues, ["5∤3", "5∤9", "5∣15", "5∤21"])
        
        XCTAssertNotNil(cancellable)
    }
}
