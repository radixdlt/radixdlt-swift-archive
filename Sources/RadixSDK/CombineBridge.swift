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

// swiftlint:disable all

// Replace `RxSwift.Disposable`
public typealias CombineDisposable = Combine.Cancellable

// Replaced: `RxSwift.BehaviourSubject`
public typealias CurrentValueSubjectNoFail<Output> = Combine.CurrentValueSubject<Output, Never>

// Replaced: `RxSwift.PublishSubject`
public typealias PassthroughSubjectNoFail<Output> = Combine.PassthroughSubject<Output, Never>

// Replaced: `RxSwift.Observable`
public typealias CombineObservable<Output> = Combine.AnyPublisher<Output, Never>

// Replaced: `RxSwift.Single`
public typealias CombineSingle<Output> = CombineObservable<Output>

// Replaced: `RxSwift.Maybe`
public typealias CombineMaybe<Output> = CombineSingle<Output?>

// Replaced: `RxSwift.Completable`
public typealias CombineCompletableSpecifyFailure<Failure> = Combine.AnyPublisher<(), Failure> where Failure: Swift.Error
public typealias CombineCompletable = CombineCompletableSpecifyFailure<Never>


// Replaced: `RxSwift.ConnectableObservable` !!! OBS !!! Not a one to one mapping, first chose
// a suitable `ConnectableObservable` conforming type, for now `MakeConnectable` is hardcoded, also chose `Upstream`, for now `AnyPublisher<Output, Never>` is chosen
public typealias CombineConnectableObservable<Output> = Combine.Publishers.MakeConnectable<CombineObservable<Output>>

// Combine lacks `ReplaySubject`, what to do?
// Figure this out, should we use `Entwine.ReplaySubject`:
// SPM available: https://github.com/tcldr/Entwine
public typealias CombineReplaySubject<Output> = PassthroughSubjectNoFail<Output>

internal func combineMigrationInProgress() -> Never {
    fatalError("Migration from RxSwift to Combine in progress")
}

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
