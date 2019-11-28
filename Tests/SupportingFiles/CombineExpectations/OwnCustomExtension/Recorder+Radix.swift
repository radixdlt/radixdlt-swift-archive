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

import Combine
import XCTest

// MARK: FirstOrError
extension PublisherExpectations {

    /// The type of the publisher expectation returned by `Recorder.firstOrError`
    public typealias FirstOrError<Input, Failure: Error> = Map<Prefix<Input, Failure>, Input>

    /// The type of the publisher expectation returned by `Recorder.prefixedOrError`
    public typealias PrefixedOrError<Input, Failure: Error> = Map<Prefix<Input, Failure>, [Input]>

}

public extension Recorder {
 
    var firstOrError: PublisherExpectations.FirstOrError<Input, Failure> {
        prefix(1).map {
            
            guard let firstElement = $0.first else {
                throw RecordingError.noElements
            }
            return firstElement
        }
    }
    
    func prefixedOrError(_ n: Int) -> PublisherExpectations.PrefixedOrError<Input, Failure> {
        prefix(n).map {
            
            let firstPrefixedElements = [Input]($0.prefix(n))
            
            guard firstPrefixedElements.count == n else {
                throw RecordingError.notEnoughElements
            }
            return firstPrefixedElements
        }
    }
}

// MARK: FirstElementOfFirstSequenceOrError
extension PublisherExpectations {
    /// The type of the publisher expectation returned by Recorder.firstElementOfFirstSequenceOrError
    public typealias FirstElementOfFirstSequenceOrError<Input: Sequence, Failure: Error> = Map<Prefix<Input, Failure>, Input.Element>
}

extension Recorder where Input: Sequence {
    
    /// Returns a publisher expectation which waits for the recorded publisher
    /// to emit one element, where element conforms to `Sequence`, or to complete.
    ///
    /// When waiting for this expectation, the publisher error is thrown if the
    /// publisher fails before publishing any element (sequence).
    ///
    /// Otherwise, the first published element is returned, or nil if the publisher
    /// completes before it publishes any element.
    ///
    /// For example:
    ///
    ///     // SUCCESS: no timeout, no error
    ///     func testMatrixFirstElementOfFirstListPublishesItsFirstElementWithoutError() throws {
    ///         let publisher = [["foo", "bar", "baz"]].publisher
    ///         let recorder = publisher.record()
    ///
    ///         // This call might throw error RecordingError.noElements
    ///         let element = try wait(for: recorder.firstElementOfFirstSequenceOrError, timeout: 1)
    ///     }
    ///
    /// This publisher expectation can be inverted:
    ///
    ///     // SUCCESS: no timeout, no error
    ///     func testPassthroughSubjectDoesNotPublishAnyElement() throws {
    ///         let publisher = PassthroughSubject<[String], Never>()
    ///         let recorder = publisher.record()
    ///         _ = try wait(for: recorder.firstElementOfFirstSequenceOrError.inverted, timeout: 1)
    ///     }
    public var firstElementOfFirstSequenceOrError: PublisherExpectations.FirstElementOfFirstSequenceOrError<Input, Failure> {
        prefix(1).map { (maybeMatrixElement: [Input]) throws -> Input.Element in
            
            let maybeFirstListOfMatrix = maybeMatrixElement.first
            
            guard let firstListOfMatrix = maybeFirstListOfMatrix else {
                throw RecordingError.noElements // No list in the matrix
            }
            
            let firstArrayOfMatrix = [Input.Element](firstListOfMatrix)
            
            guard let firstElementOfFirstArray = firstArrayOfMatrix.first else {
                throw RecordingError.noElements // No element of first array
            }
            return firstElementOfFirstArray
        }
    }
}

// MARK: Expect Error
extension PublisherExpectations {
    /// The type of the publisher expectation returned by Recorder.specificError
    public typealias ExpectErrorType<Input, ExpectedError: Error & Equatable, Failure: Error> = Map<Map<Recording<Input, Failure>, Combine.Subscribers.Completion<Failure>>, ExpectedError>
}

extension Recorder {
    
    public func expectError<ExpectedError: Error & Equatable>(
        _ mapFailureToExpectedError: @escaping (Failure) throws -> ExpectedError = { failure in
        guard let expectedError = failure as? ExpectedError else {
            throw RecordingError.failedToMapErrorFromFailureToExpectedErrorType(
                expectedErrorType: ExpectedError.self,
                butGotFailure: failure
            )
        }
        return expectedError
        }
    ) -> PublisherExpectations.ExpectErrorType<Input, ExpectedError, Failure> {
        return expectError(ofType: ExpectedError.self, mapFailureToExpectedError)
    }
    
    public func expectError<ExpectedError: Error & Equatable>(
        ofType type: ExpectedError.Type,
        _ mapFailureToExpectedError: @escaping (Failure) throws -> ExpectedError = { failure in
            guard let expectedError = failure as? ExpectedError else {
                throw RecordingError.failedToMapErrorFromFailureToExpectedErrorType(
                    expectedErrorType: ExpectedError.self,
                    butGotFailure: failure
                )
            }
            return expectedError
        }
    ) -> PublisherExpectations.ExpectErrorType<Input, ExpectedError, Failure> {
        self.completion.map { completion throws -> ExpectedError in
            switch completion {
            case .finished:
                throw RecordingError.expectedPublisherToFailButGotFinish(expectedErrorType: type)
            case .failure(let failure):
                return try mapFailureToExpectedError(failure)
            }
        }
    }
}
