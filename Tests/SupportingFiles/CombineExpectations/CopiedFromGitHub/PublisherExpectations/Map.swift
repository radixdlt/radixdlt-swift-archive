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
    /// A publisher expectation that transforms the value of a base expectation.
    ///
    /// This expectation has no public initializer.
    public struct Map<Base: PublisherExpectation, Output>: PublisherExpectation {
        let base: Base
        let transform: (Base.Output) throws -> Output
        
        public func _setup(_ expectation: XCTestExpectation) {
            base._setup(expectation)
        }
        
        public func _value() throws -> Output {
            try transform(base._value())
        }
    }
}

extension PublisherExpectations.Map: InvertablePublisherExpectation where Base: InvertablePublisherExpectation { }

extension PublisherExpectation {
    /// Returns a publisher expectation that transforms the value of the
    /// base expectation.
    func map<T>(_ transform: @escaping (Output) throws -> T) -> PublisherExpectations.Map<Self, T> {
        PublisherExpectations.Map(base: self, transform: transform)
    }
}
