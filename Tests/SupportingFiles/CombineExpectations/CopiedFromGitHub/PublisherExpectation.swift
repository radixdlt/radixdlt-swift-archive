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

/// A name space for publisher expectations
public enum PublisherExpectations { }

/// The protocol for publisher expectations.
///
/// You can build publisher expectations from Recorder returned by the
/// `Publisher.record()` method. For example:
///
///     // SUCCESS: no timeout, no error
///     func testArrayPublisherPublishesArrayElements() throws {
///         let publisher = ["foo", "bar", "baz"].publisher
///         let recorder = publisher.record()
///         let expectation = recorder.elements
///         let elements = try wait(for: expectation, timeout: 1)
///         XCTAssertEqual(elements, ["foo", "bar", "baz"])
///     }
public protocol PublisherExpectation {
    associatedtype Output
    
    /// Implementation detail: don't use this method.
    /// :nodoc:
    func _setup(_ expectation: XCTestExpectation)
    
    /// Implementation detail: don't use this method.
    /// :nodoc:
    func _value() throws -> Output
}

extension TestCase {
    /// Waits for the publisher expectation to fulfill, and returns the
    /// expected value.
    ///
    /// For example:
    ///
    ///     // SUCCESS: no timeout, no error
    ///     func testArrayPublisherPublishesArrayElements() throws {
    ///         let publisher = ["foo", "bar", "baz"].publisher
    ///         let recorder = publisher.record()
    ///         let elements = try wait(for: recorder.elements, timeout: 1)
    ///         XCTAssertEqual(elements, ["foo", "bar", "baz"])
    ///     }
    ///
    /// - parameter publisherExpectation: The publisher expectation.
    /// - parameter timeout: The number of seconds within which the expectation
    ///   must be fulfilled.
    /// - parameter description: A string to display in the test log for the
    ///   expectation, to help diagnose failures.
    /// - throws: An error if the expectation fails.
    public func wait<R: PublisherExpectation>(
        for publisherExpectation: R,
        timeout: TimeInterval,
        description: String = "",
        
        file: StaticString = #file,
        line: UInt = #line
    )
        throws -> R.Output
    {
        let expectation = self.expectation(description: description)
        publisherExpectation._setup(expectation)
        if XCTWaiter().wait(for: [expectation], timeout: timeout) ==  .timedOut {
            self.recordFailure(
                withDescription: "Exceeded timeout of \(timeout) seconds, with unfulfilled expectations: \(description)",
                inFile: file.description,
                atLine: Int(line),
                expected: false
            )
        }
        return try publisherExpectation._value()
    }
}
