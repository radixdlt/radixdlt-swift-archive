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

// Replaced: `RxSwift.BehaviourSubject`
public typealias CurrentValueSubjectNoFail<Element> = Combine.CurrentValueSubject<Element, Never>

// Replaced: `RxSwift.PublishSubject`
public typealias PassthroughSubjectNoFail<Element> = Combine.PassthroughSubject<Element, Never>

// Replaced: `RxSwift.Observable`
public typealias CombineObservable<Element> = Combine.AnyPublisher<Element, Never>

// Replaced: `RxSwift.Single`
public typealias CombineSingle<Element> = Combine.Future<Element, Never>

// Replaced: `RxSwift.Maybe`
public typealias CombineMaybe<Element> = CombineSingle<Element?>

// Replaced: `RxSwift.Completable`
public typealias CombineCompletableSpecifyError<Error> = Combine.AnyPublisher<(), Error> where Error: Swift.Error
public typealias CombineCompletable = CombineCompletableSpecifyError<Never>

// Replaced: `RxSwift.ConnectableObservable` !!! OBS !!! Not a one to one mapping, first chose
// a suitable `ConnectableObservable` conforming type, for now `MakeConnectable` is hardcoded, also chose `Upstream`, for now `AnyPublisher<Element, Never>` is chosen
public typealias CombineConnectableObservable<Element> = Combine.Publishers.MakeConnectable<CombineObservable<Element>>


internal func combineMigrationInProgress() -> Never {
    fatalError("Migration from RxSwift to Combine in progress")
}

// extension CombineObservable
public extension Publisher {
    
    func asCompletable() -> CombineCompletable {
        combineMigrationInProgress()
    }
    
    func filterMap<Other>(_ selector: @escaping (Element) throws -> CombineObservable<Other>) -> CombineObservable<Other> {
        combineMigrationInProgress()
    }
    
    func cache() -> CombineObservable<Element> {
        combineMigrationInProgress()
    }
    
    func firstOrError() -> CombineSingle<Element> {
        combineMigrationInProgress()
    }
    
    func lastOrError() -> CombineSingle<Element> {
        combineMigrationInProgress()
    }
    
    func flatMapIterable<Other>(_ selector: @escaping (Element) -> [Other]) -> CombineObservable<Other> {
        combineMigrationInProgress()
    }
    
    func flatMapToSingle<Other>(_ selector: @escaping (Element) throws -> CombineSingle<Other>) -> CombineSingle<Other> {
        combineMigrationInProgress()
    }
    
    func flatMapCompletable(_ selector: @escaping (Element) -> CombineCompletable) -> CombineCompletable {
    combineMigrationInProgress()
    }
    
    func flatMapSingle<Other>(_ selector: @escaping (Element) throws -> CombineSingle<Other>) -> CombineObservable<Other> {
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
    func andThen(_ other: CombineObservable<Element>) -> CombineObservable<Element> {
        combineMigrationInProgress()
        
    }
//    where Other: Publisher, Other.Output == Self.Output, Other.Failure == Self.Failure
}

public typealias DisposeBag = Set<AnyCancellable>
public extension Cancellable {
    func disposed(by setOfCancellables: DisposeBag) {
          combineMigrationInProgress()
    }
}

// extension CombineSingle
public extension Publisher {
    
    func subscribe(onNext: ((Element) -> Void)? = nil, onError: ((Swift.Error) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil)
        -> Cancellable {
            combineMigrationInProgress()
    }
    
    func `do`(
        onSuccess: ((Element) -> Void)? = nil,
        onFailure: ((Error) -> Void)? = nil
    ) -> Self {
        combineMigrationInProgress()
    }
    
    
    func flatMapObservable<Other>(_ selector: @escaping (Element) throws -> CombineObservable<Other>) -> CombineObservable<Other> {
        combineMigrationInProgress()
    }
    
    func cache() -> CombineSingle<Element> {
        combineMigrationInProgress()
    }
    
    func asSingle() -> CombineSingle<Element> {
        combineMigrationInProgress()
    }
        
    func flatMapCompletableVoid(_ selector: @escaping () -> CombineCompletable) -> CombineCompletable {
        combineMigrationInProgress()
    }
    
    static func create(_ creation: (AnySubscriber<Element, Never>) -> Cancellable) -> Self {
        combineMigrationInProgress()
    }
    
    static func deferred(_ creation: () -> Self) -> Self {
        combineMigrationInProgress()
    }
    
    
    static func just(_ foobar: Element) -> Self {
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
        resultSelector: @escaping ([Collection.Element.Element]) throws -> Element
    ) -> CombineObservable<Element> where Collection.Element: Publisher {
        combineMigrationInProgress()
    }

    static func from(_ elements: [Element]) -> CombineObservable<Element> {
        combineMigrationInProgress()
    }
    
    func `do`(
        onNext: ((Element) throws -> Void)? = nil,
        afterNext: ((Element) throws -> Void)? = nil,
        onError: ((Swift.Error) throws -> Void)? = nil,
        afterError: ((Swift.Error) throws -> Void)? = nil, onCompleted: (() throws -> Void)? = nil, afterCompleted: (() throws -> Void)? = nil, onSubscribe: (() -> Void)? = nil, onSubscribed: (() -> Void)? = nil, onDispose: (() -> Void)? = nil)
        -> CombineObservable<Element> {
            combineMigrationInProgress()
    }
    
    func ignoreElementsObservable() -> CombineObservable<Element> {
        combineMigrationInProgress()
    }
    
    func take(_ n: Int) -> CombineObservable<Element> {
        combineMigrationInProgress()
    }
}

// extension CombineObservable
public extension Publisher where Element: OptionalType {
    func ifNilReturnEmpty() -> CombineObservable<Element.Wrapped> {
        
        combineMigrationInProgress()
    }
    
    func ifNil(throw error: Error) -> CombineObservable<Element.Wrapped> {
        
        combineMigrationInProgress()
    }
    
    func ifNilKill(_ message: String) -> CombineObservable<Element.Wrapped> {
        
        combineMigrationInProgress()
    }
    
    func replaceNilWith(_ element: Element) -> CombineObservable<Element.Wrapped> {
        combineMigrationInProgress()
        
    }
}

// extension ObservableType
public extension Publisher where Element: LengthMeasurable {
    func ifEmpty<ErrorType>(throw errorIfEmpty: ErrorType) -> CombineObservable<Element> where ErrorType: Swift.Error {
         combineMigrationInProgress()
    }
}

public extension Publisher where Element: Sequence {
    func first<ErrorType>(ifEmptyThrow errorIfEmpty: ErrorType) -> CombineObservable<Element.Element> where ErrorType: Swift.Error {
        combineMigrationInProgress()
    }
}

extension Publisher where Element == Void {
    func flatMapCompletableVoid(_ selector: @escaping () -> CombineCompletable) -> CombineCompletable {
        combineMigrationInProgress()
    }
}

public extension Publisher {
    
    typealias Element = Output
    typealias Error = Failure
    
    func toBlocking(timeout: TimeInterval = 1) -> Combine.Publishers.BlockingPublisher<Output, Failure> {
        combineMigrationInProgress()
    }
    
}

public extension Combine.Publishers {
    struct BlockingPublisher<Output, Failure> where Failure: Swift.Error {}
}

public extension Subject {
    func onNext(_ element: Element) {
        self.send(element)
    }
    var hasObservers: Bool {
        combineMigrationInProgress()
    }
    func asObservable() -> CombineObservable<Element> {
        combineMigrationInProgress()
    }
}
