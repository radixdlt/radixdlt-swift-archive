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
public typealias CombineSingle<Output> = Combine.Future<Output, Never>

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

// extension CombineObservable
public extension Publisher {
    
    func asCompletable() -> CombineCompletable {
        combineMigrationInProgress()
    }
    
    func filterMap<Other>(_ selector: @escaping (Output) throws -> CombineObservable<Other>) -> CombineObservable<Other> {
        combineMigrationInProgress()
    }
    
    func cache() -> CombineObservable<Output> {
        combineMigrationInProgress()
    }
    
    func firstOrError() -> CombineSingle<Output> {
        combineMigrationInProgress()
    }
    
    func lastOrError() -> CombineSingle<Output> {
        combineMigrationInProgress()
    }
    
    func flatMapIterable<Other>(_ selector: @escaping (Output) -> [Other]) -> CombineObservable<Other> {
        combineMigrationInProgress()
    }
    
    func flatMapToSingle<Other>(_ selector: @escaping (Output) throws -> CombineSingle<Other>) -> CombineSingle<Other> {
        combineMigrationInProgress()
    }
    
    func flatMapCompletable(_ selector: @escaping (Output) -> CombineCompletable) -> CombineCompletable {
    combineMigrationInProgress()
    }
    
    func flatMapSingle<Other>(_ selector: @escaping (Output) throws -> CombineSingle<Other>) -> CombineObservable<Other> {
    combineMigrationInProgress()
    }
    
    func mapToVoid() -> CombineObservable<Void> {
        combineMigrationInProgress()
    }
    
    func ofType<SomeType>(_ type: SomeType) -> CombineObservable<SomeType> {
        combineMigrationInProgress()
    }
}

// extension CombineCompletable
public extension Publisher {
    func andThen(_ other: CombineObservable<Output>) -> CombineObservable<Output> {
        combineMigrationInProgress()
        
    }
}

public typealias DisposeBag = Set<AnyCancellable>
public extension Cancellable {
    func disposed(by setOfCancellables: DisposeBag) {
          combineMigrationInProgress()
    }
}

// extension CombineSingle
public extension Publisher {
    
    func subscribe(onNext: ((Output) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil)
        -> Cancellable {
            combineMigrationInProgress()
    }
    
    func `do`(
        onSuccess: ((Output) -> Void)? = nil,
        onFailure: ((Error) -> Void)? = nil
    ) -> Self {
        combineMigrationInProgress()
    }
    
    
    func flatMapObservable<Other>(_ selector: @escaping (Output) throws -> CombineObservable<Other>) -> CombineObservable<Other> {
        combineMigrationInProgress()
    }
    
    func cache() -> CombineSingle<Output> {
        combineMigrationInProgress()
    }
    
    func asSingle() -> CombineSingle<Output> {
        combineMigrationInProgress()
    }
        
    func flatMapCompletableVoid(_ selector: @escaping () -> CombineCompletable) -> CombineCompletable {
        combineMigrationInProgress()
    }
    
    static func create(_ creation: (AnySubscriber<Output, Never>) -> Cancellable) -> Self {
        combineMigrationInProgress()
    }
    
    static func deferred(_ creation: () -> Self) -> Self {
        combineMigrationInProgress()
    }
    
    
    static func just(_ foobar: Output) -> Self {
        combineMigrationInProgress()
    }
    
    static func merge<A, B>(_ foobarA: A, _ foobarB: B) -> Self where A: Publisher, B: Publisher, A.Output == Self.Output, B.Output == Self.Output, A.Failure == Self.Failure, B.Failure == Self.Failure {
        combineMigrationInProgress()
    }
    
    static func combineLatest<A, B>(_ foobarA: A, _ foobarB: B) -> Self where A: Publisher, B: Publisher, A.Output == Self.Output, B.Output == Self.Output, A.Failure == Self.Failure, B.Failure == Self.Failure {
        combineMigrationInProgress()
    }
    
    static func combineLatest<Collection: Swift.Collection>(
        _ collection: Collection,
        resultSelector: @escaping ([Collection.Element.Output]) throws -> Output
    ) -> CombineObservable<Output> where Collection.Element: Publisher {
        combineMigrationInProgress()
    }

    static func from(_ Outputs: [Output]) -> CombineObservable<Output> {
        combineMigrationInProgress()
    }
    
    func `do`(
        onNext: ((Output) throws -> Void)? = nil,
        afterNext: ((Output) throws -> Void)? = nil,
        onError: ((Swift.Error) throws -> Void)? = nil,
        afterError: ((Swift.Error) throws -> Void)? = nil, onCompleted: (() throws -> Void)? = nil, afterCompleted: (() throws -> Void)? = nil, onSubscribe: (() -> Void)? = nil, onSubscribed: (() -> Void)? = nil, onDispose: (() -> Void)? = nil)
        -> CombineObservable<Output> {
            combineMigrationInProgress()
    }
    
    func ignoreOutputsObservable() -> CombineObservable<Output> {
        combineMigrationInProgress()
    }
    
    func take(_ n: Int) -> CombineObservable<Output> {
        combineMigrationInProgress()
    }
}

// extension CombineObservable
public extension Publisher where Output: OptionalType {
    func ifNilReturnEmpty() -> CombineObservable<Output.Wrapped> {
        
        combineMigrationInProgress()
    }
    
    func ifNil(throw error: Swift.Error) -> CombineObservable<Output.Wrapped> {
        
        combineMigrationInProgress()
    }
    
    func ifNilKill(_ message: String) -> CombineObservable<Output.Wrapped> {
        
        combineMigrationInProgress()
    }
    
    func replaceNilWith(_ Output: Output) -> CombineObservable<Output.Wrapped> {
        combineMigrationInProgress()
        
    }
}

// extension ObservableType
public extension Publisher where Output: LengthMeasurable {
    func ifEmpty<ErrorType>(throw errorIfEmpty: ErrorType) -> CombineObservable<Output> where ErrorType: Swift.Error {
         combineMigrationInProgress()
    }
}


extension Publisher where Output == Void {
    func flatMapCompletableVoid(_ selector: @escaping () -> CombineCompletable) -> CombineCompletable {
        combineMigrationInProgress()
    }
}

public extension Publisher {
    func toBlocking(timeout: TimeInterval = 1) -> Combine.Publishers.BlockingPublisher<Output, Failure> {
        combineMigrationInProgress()
    }
    
}

public extension Combine.Publishers {
    struct BlockingPublisher<Output, Failure> where Failure: Swift.Error {}
}

public extension Subject {
    func onNext(_ Output: Output) {
        self.send(Output)
    }
    var hasObservers: Bool {
        combineMigrationInProgress()
    }
    func asObservable() -> CombineObservable<Output> {
        combineMigrationInProgress()
    }
}
