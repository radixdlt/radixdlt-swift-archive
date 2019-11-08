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

// swiftlint:disable opening_brace

// MARK: Internal
/* Internal for test purposes only, otherwise `private`. */
internal extension Publisher {
    func prefix<CompletionTrigger>(
        untilEventFrom completionTriggeringPublisher: CompletionTrigger,
        completionTriggerOptions: Publishers.CompletionTriggerOptions
    ) -> AnyPublisher<Output, Failure> where CompletionTrigger: Publisher {

        guard completionTriggerOptions != .output else {
            // Fallback to Combine's bundled operator
            return self.prefix(untilOutputFrom: completionTriggeringPublisher).eraseToAnyPublisher()
        }

        let completionAsOutputSubject = PassthroughSubject<Void, Never>()
        
        var cancellable: Cancellable? = completionTriggeringPublisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        guard completionTriggerOptions.contains(.failure) else { return }
                        completionAsOutputSubject.send()
                    case .finished:
                        guard completionTriggerOptions.contains(.finish) else { return }
                        completionAsOutputSubject.send()
                    }
                },
                receiveValue: { _ in
                    guard completionTriggerOptions.contains(.output) else { return }
                    completionAsOutputSubject.send()
            }
        )
        
        func cleanUp() {
            cancellable = nil
        }
        
        return self.prefix(untilOutputFrom: completionAsOutputSubject)
            .handleEvents(
                receiveCompletion: { _ in cleanUp() },
                receiveCancel: {
                    cancellable?.cancel()
                    cleanUp()
            }
        )
            .eraseToAnyPublisher()
        
    }
}

// MARK: Public

public extension Publisher {
    
    func prefix<CompletionTrigger>(
        untilCompletionFrom completionTriggeringPublisher: CompletionTrigger
    ) -> AnyPublisher<Output, Failure>
        where CompletionTrigger: Publisher
    {
        prefix(untilEventFrom: completionTriggeringPublisher, completionTriggerOptions: .completion)
    }
    
    func prefix<CompletionTrigger>(
        untilFinishFrom completionTriggeringPublisher: CompletionTrigger
    ) -> AnyPublisher<Output, Failure>
        where CompletionTrigger: Publisher
    {
        prefix(untilEventFrom: completionTriggeringPublisher, completionTriggerOptions: .finish)
    }
    
    func prefix<CompletionTrigger>(
        untilFailureFrom completionTriggeringPublisher: CompletionTrigger
    ) -> AnyPublisher<Output, Failure>
        where CompletionTrigger: Publisher
    {
        prefix(untilEventFrom: completionTriggeringPublisher, completionTriggerOptions: .failure)
    }
    
    func prefix<CompletionTrigger>(
        untilOutputOrFinishFrom completionTriggeringPublisher: CompletionTrigger
    ) -> AnyPublisher<Output, Failure>
        where CompletionTrigger: Publisher
    {
        prefix(untilEventFrom: completionTriggeringPublisher, completionTriggerOptions: [.output, .finish])
    }
    
    ///
    func prefix<CompletionTrigger>(
        untilOutputOrCompletionFrom completionTriggeringPublisher: CompletionTrigger
    ) -> AnyPublisher<Output, Failure>
        where CompletionTrigger: Publisher
    {
        prefix(untilEventFrom: completionTriggeringPublisher, completionTriggerOptions: [.output, .completion])
    }
}

// MARK: Publishers + CompletionTriggerOptions
public extension Publishers {
    struct CompletionTriggerOptions: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

public extension Publishers.CompletionTriggerOptions {
    static let output   = Self(rawValue: 1 << 0)
    static let finish   = Self(rawValue: 1 << 1)
    static let failure  = Self(rawValue: 1 << 2)
    
    static let completion: Self =  [.finish, .failure]
    static let all: Self =  [.output, .finish, .failure]
}

// swiftlint:enable opening_brace
