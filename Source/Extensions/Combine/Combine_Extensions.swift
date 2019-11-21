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
import Combine

// MARK: Typealias
public typealias Single<Output, Failure> = AnyPublisher<Output, Failure> where Failure: Swift.Error
public typealias Completable = AnyPublisher<Never, Never>

// MARK: Any
public extension Publisher {
    
    /// Similar to `ignoreOutput`, but the type of `Output` remains intact, that is all elements are ignored
    /// ("droppped"), but completion event get published. But whereas the `Output` type of the `ignoreOutput`
    /// operator, changes to `Never`, this operator keeps it.
    func dropAll() -> Publishers.Filter<Self> { filter { _ in false } }

    /// `ignoreOutput` transforming the `Output` type to some specified type `T`, even though no element
    /// is published, when using chaining this operator, .e.g. with an `append`, it might be advantagous
    /// to be able to specify the type (since `append` requires the outputs of both publishers to be equal).
    func ignoreOutput<T>(mapToType _: T.Type) -> AnyPublisher<T, Failure> {
        ignoreOutput()
            .flatMap { _ in Empty<T, Failure>() }
            .eraseToAnyPublisher()
    }
    
    func compactMap<T>(typeAs _: T.Type) -> AnyPublisher<T, Failure> {
        compactMap { $0 as? T }.eraseToAnyPublisher()
    }
    
    func mapToVoid() -> AnyPublisher<Void, Failure> {
        map { _ in Void() }.eraseToAnyPublisher()
    }

}

// MARK: andThen
public protocol BaseForAndThen {}
extension Publishers.IgnoreOutput: BaseForAndThen {}
extension Combine.Future: BaseForAndThen {}

extension Publisher where Self: BaseForAndThen, Self.Failure == Never {
    func andThen<Then>(_ thenPublisher: @autoclosure () -> Then) -> AnyPublisher<Then.Output, Never> where Then: Publisher, Then.Failure == Failure {
        return
            flatMap { _ in Empty<Then.Output, Never>(completeImmediately: true) } // same as `init()`
                .append(thenPublisher())
                .eraseToAnyPublisher()
    }
}

// MARK: Output: OptionalType
public extension Publisher where Output: OptionalType {
    
    func replaceNilWithEmpty() -> AnyPublisher<Output.Wrapped, Failure> {
        return compactMap { $0.value }.eraseToAnyPublisher()
    }
}

// MARK: Output: Sequence
public extension Publisher where Output: Sequence, Failure == Never {
    
    /// Only available when `Output` conforms to `Sequence`, this operator flattens the sequence output to a Publisher of `Sequence.Element`, e.g. `Publisher<[X]> -> Publisher<X>`
    func flattenSequence() -> AnyPublisher<Output.Element, Never> {
        map { $0.publisher }.switchToLatest()
            .eraseToAnyPublisher()
    }
}

public extension Publisher {
    func crashOnFailure(
        prefix: String = "TODO Combine, handle error",
        
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) -> AnyPublisher<Output, Never> {
       
        return self.tryCatch { error -> AnyPublisher<Output, Failure> in
            Swift.print("\(prefix) - line: \(line), in function: \(function), in file: \(file)")
            unexpectedlyMissedToCatch(error: error)
        }
        .assertNoFailure()
        .eraseToAnyPublisher()
    }
}
