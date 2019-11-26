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
    
    // swiftlint:disable opening_brace
    
    /// A throwing version of `flatMap`
    func tryFlatMap<T, P>(
        maxPublishers: Subscribers.Demand = .unlimited,
        _ transform: @escaping (Self.Output) throws -> P
    ) -> AnyPublisher<T, Failure>
        where T == P.Output, P: Publisher, Self.Failure == P.Failure
    {
        // swiftlint:enable opening_brace
        let failureSubject = PassthroughSubject<T, Failure>()
        
        let flatMapped = self.flatMap(maxPublishers: maxPublishers) { (output: Self.Output) -> AnyPublisher<T, Failure> in
            
            do {
                return try transform(output)
                    .eraseToAnyPublisher()
            } catch {
                guard let failure = error as? Failure else {
                    unexpectedlyMissedToCatch(error: error)
                }
                failureSubject.send(completion: .failure(failure))
                
                // Whether we pass true or false to `completeImmediately` is irrelevant, since the
                // merged publisher returned from this function will complete with an error
                // when the 'failureSubject' sends the error on the previous line.
                return Empty<T, Failure>(completeImmediately: Bool.irrelevant)
                    .eraseToAnyPublisher()
            }
        }
        
        return flatMapped
            .merge(with: failureSubject)
            .prefix(untilCompletionFrom: self)
            .eraseToAnyPublisher()
    }
}

private extension Bool {
    static let irrelevant = false
}
