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

/// Behavior for the `prefixWhile(_ behavior:predicate:)` operator, inspired by [RxSwift][github_rxswift]
///
/// [github_rxswift]: https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Observables/TakeUntil.swift#L43-50
public enum PrefixWhileBehavior: Int, Equatable {
    /// Include the last value (output) matching the predicate.
    case inclusive
    
    /// Exclude the last value (output) matching the predicate.
    case exclusive
}

/* Internal for test purposes only, otherwise `private`. */
internal extension Publisher where Failure == Never {
    func prefixWhile(
        behavior: PrefixWhileBehavior = .inclusive,
        conditionIsTrue predicate: @escaping (Output) -> Bool
    ) -> AnyPublisher<Output, Failure> {
        
        let fulfillingPredicate =  self.prefix(while: predicate).eraseToAnyPublisher()
        
        guard behavior == .inclusive else {
            // Fallback to Combine's bundled operator
            return fulfillingPredicate
        }

        let completionTriggeringValue = self.filter { !predicate($0) }.first()
        
        return fulfillingPredicate.merge(with: completionTriggeringValue).eraseToAnyPublisher()
        
    }
}
