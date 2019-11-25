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


import Combine
import XCTest

extension PublisherExpectations {
    /// A publisher expectation which waits for a publisher to
    /// complete successfully.
    ///
    /// When waiting for this expectation, an error is thrown if the publisher
    /// does not complete on time.
    ///
    /// For example:
    ///
    ///     // SUCCESS: no timeout, no error
    ///     func testArrayPublisherRecording() throws {
    ///         let publisher = ["foo", "bar", "baz"].publisher
    ///         let recorder = publisher.record()
    ///         let recording = try wait(for: recorder.recording, timeout: 1)
    ///         XCTAssertEqual(recording.output, ["foo", "bar", "baz"])
    ///         if case let .failure(error) = recording.completion {
    ///             XCTFail("Unexpected error \(error)")
    ///         }
    ///     }
    public struct Recording<Input, Failure: Error>: PublisherExpectation {
        let recorder: Recorder<Input, Failure>
        
        public func _setup(_ expectation: XCTestExpectation) {
            recorder.fulfillOnCompletion(expectation)
        }
        
        public func _value() throws -> Record<Input, Failure>.Recording {
            let (elements, completion) = recorder.elementsAndCompletion
            if let completion = completion {
                return Record<Input, Failure>.Recording(output: elements, completion: completion)
            } else {
                throw RecordingError.notCompleted
            }
        }
    }
}
