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

public extension Publisher {
    
    /// Crashes on value. Call this after `ignoreOutput` or `filter { false }` etc.
    func sink(
        receiveFinish finishHandler: (() -> Void)? = nil,
        receiveError errorHandler: @escaping (Failure) -> Void
    ) -> Cancellable {
        
        sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error): errorHandler(error)
                case .finished:
                    finishHandler?()
                }
            },
            receiveValue: { value in
                incorrectImplementation("Expected to never get any outputted value, but got: \(value). Did you intend to call `ignoreOutput()` before calling this method?")
            }
        )
    }
}

// MARK: Failure == Never
public extension Publisher where Failure == Never {
    
    /// Crashes on value. Call this after `ignoreOutput` or `filter { false }` etc.
    func sink(
        receiveFinish finishHandler: @escaping () -> Void
    ) -> Cancellable {
        
        sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure: fatalError("Not possible, `Failure` == `Never`")
                case .finished:
                    finishHandler()
                }
            },
            receiveValue: { value in
                incorrectImplementation("Expected to never get any outputted value, but got: \(value). Did you intend to call `ignoreOutput()` before calling this method?")
            }
        )
    }
}

// MARK: Output == Never
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

// MARK: Output == Void
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

