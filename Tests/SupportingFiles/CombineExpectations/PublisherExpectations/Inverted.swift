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

/// The protocol for publisher expectations that can be inverted.
public protocol InvertablePublisherExpectation: PublisherExpectation { }

extension PublisherExpectations {
    /// A publisher expectation that fails if the base expectation is fulfilled.
    ///
    /// When waiting for this expectation, you receive the same result and
    /// eventual error as the base expectation.
    ///
    /// For example:
    ///
    ///     // SUCCESS: no timeout, no error
    ///     func testPassthroughSubjectDoesNotFinish() throws {
    ///         let publisher = PassthroughSubject<String, Never>()
    ///         let recorder = publisher.record()
    ///         try wait(for: recorder.finished.inverted, timeout: 1)
    ///     }
    public struct Inverted<Base: PublisherExpectation>: InvertablePublisherExpectation {
        let base: Base
        
        public func _setup(_ expectation: XCTestExpectation) {
            base._setup(expectation)
            expectation.isInverted.toggle()
        }
        
        public func _value() throws -> Base.Output {
            try base._value()
        }
    }
}

extension InvertablePublisherExpectation {
    /// Returns an inverted expectation which fails if the base expectation
    /// fulfills within the specified timeout.
    ///
    /// When waiting for an inverted expectation, you receive the same result
    /// and eventual error as the base expectation.
    ///
    /// For example:
    ///
    ///     // SUCCESS: no timeout, no error
    ///     func testPassthroughSubjectDoesNotFinish() throws {
    ///         let publisher = PassthroughSubject<String, Never>()
    ///         let recorder = publisher.record()
    ///         try wait(for: recorder.finished.inverted, timeout: 1)
    ///     }
    public var inverted: PublisherExpectations.Inverted<Self> {
        PublisherExpectations.Inverted(base: self)
    }
}
