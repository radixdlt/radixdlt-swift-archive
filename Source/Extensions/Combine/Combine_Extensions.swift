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

public extension Publisher where Output == Never {
    func sink(receiveCompletion completionHandler: @escaping (Subscribers.Completion<Failure>) -> Void) -> Cancellable {
        return sink(
            receiveCompletion: { completionHandler($0) },
            receiveValue: { _ in /* Doing nothing with `Never` output */ }
        )
    }
}

public extension Publisher where Output == Never, Failure == Never {
    func sink(receiveFinished finishHandler: @escaping () -> Void) -> Cancellable {
        return sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished: finishHandler()
                case .failure: incorrectImplementation("Should never fail, `Failure` == `Never`")
                }
        }
        )
    }
}

public extension Publisher where Output == Void, Failure == Never {
    func sink(receiveFinished finishHandler: @escaping () -> Void) -> Cancellable {
        return sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished: finishHandler()
                case .failure: incorrectImplementation("Should never fail, `Failure` == `Never`")
                }
            },
            receiveValue: { _ in /* Doing nothing with `Void` output */ }
        )
    }
}

public extension Publisher {
    func ofType<T>(_ : T.Type) -> AnyPublisher<T, Failure> {
        compactMap { $0 as? T }.eraseToAnyPublisher()
    }
}

public extension Publisher where Output == Never, Failure == Never {
    func asFuture() -> Future<Void, Never> {
        Future<Void, Never> { promise in
            // TODO ok to ignore returned Cancellable?
            _ = self.sink(receiveFinished: { promise(.success(void)) })
        }
    }
    
}

public typealias Single<Output, Failure> = AnyPublisher<Output, Failure> where Failure: Swift.Error

public extension Publisher where Output: OptionalType {
    func replaceNilWithEmpty() -> AnyPublisher<Output.Wrapped, Failure> {
        return flatMap { (wrappedOptional: Output) -> AnyPublisher<Output.Wrapped, Failure> in
            if wrappedOptional.value != nil {
                return self.map { $0.value! }.eraseToAnyPublisher()
            } else {
                return Empty<Output.Wrapped, Failure>().eraseToAnyPublisher()
            }
        }.eraseToAnyPublisher()
    }
}

public extension Publisher where Output: Sequence, Failure == Never {
    
    /// Only available when `Output` conforms to `Sequence`, this operator flattens the sequence output to a Publisher of `Sequence.Element`, e.g. `Publisher<[X]> -> Publisher<X>`
    func flattenSequence() -> AnyPublisher<Output.Element, Never> {
        map { $0.publisher }.switchToLatest()
            .eraseToAnyPublisher()
    }
}
