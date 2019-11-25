// Copyright (C) 2019 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Manually copied from: https://github.com/groue/CombineExpectations
// awaiting possible Carthage support when issue is fix: https://github.com/groue/CombineExpectations/issues/1


import XCTest

extension PublisherExpectations {
    /// A publisher expectation which waits for a publisher to emit a certain
    /// number of elements, or to complete.
    ///
    /// The awaited array may contain less than `maxLength` elements, if the
    /// publisher completes early.
    ///
    /// When waiting for this expectation, an error is thrown if the publisher
    /// fails before `maxLength` elements are published.
    ///
    /// For example:
    ///
    ///     // SUCCESS: no timeout, no error
    ///     func testArrayOfThreeElementsPublishesTwoFirstElementsWithoutError() throws {
    ///         let publisher = ["foo", "bar", "baz"].publisher
    ///         let recorder = publisher.record()
    ///         let elements = try wait(for: recorder.prefix(2), timeout: 1)
    ///         XCTAssertEqual(elements, ["foo", "bar"])
    ///     }
    public struct Prefix<Input, Failure: Error>: InvertablePublisherExpectation {
        let recorder: Recorder<Input, Failure>
        let maxLength: Int
        
        init(recorder: Recorder<Input, Failure>, maxLength: Int) {
            precondition(maxLength >= 0, "Can't take a prefix of negative length")
            self.recorder = recorder
            self.maxLength = maxLength
        }
        
        public func _setup(_ expectation: XCTestExpectation) {
            if maxLength == 0 {
                // Such an expectation is immediately fulfilled, by essence.
                expectation.expectedFulfillmentCount = 1
                expectation.fulfill()
            } else {
                expectation.expectedFulfillmentCount = maxLength
                recorder.fulfillOnInput(expectation)
            }
        }
        
        public func _value() throws -> [Input] {
            let (elements, completion) = recorder.elementsAndCompletion
            if elements.count >= maxLength {
                return Array(elements.prefix(maxLength))
            }
            if case let .failure(error) = completion {
                throw error
            }
            return elements
        }
    }
}
