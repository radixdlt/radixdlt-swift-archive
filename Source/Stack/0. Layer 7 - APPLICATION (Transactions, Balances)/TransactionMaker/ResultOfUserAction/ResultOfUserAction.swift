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

public enum ResultOfUserAction: Throwing {
    
    case pendingSending(
        /// Ugly hack to retain this Publisher
        cachedAtom: AnyPublisher<SignedAtom, Never>,
        updates: AnyPublisher<SubmitAtomAction, Never>,
        completable: Completable
    )
    
    case failedToStageAction(FailedToStageAction)
}

// MARK: Convenience Init
public extension ResultOfUserAction {
    
    init(
        submitAtomStatusUpdatesPublisher updates: AnyPublisher<SubmitAtomAction, Never>,
        cachedAtom: AnyPublisher<SignedAtom, Never>
    ) {
        
        let completable: Completable = updates
            .compactMap(typeAs: SubmitAtomActionStatus.self)
            .last()
            .flatMap { submitAtomActionStatus -> AnyPublisher<Never, Never> in
                let statusEvent = submitAtomActionStatus.statusEvent
                switch statusEvent {
                    
                case .stored:
                    // Complete
                    return Empty<Never, Never>(completeImmediately: true).eraseToAnyPublisher()
                    
                case .notStored(let reason):
                    log.error("Not stored, reason: \(reason)")
                    incorrectImplementation("TODO Combine migration, fix error handling here, Atom was not stored, reason: \(reason.error)")
                }
            }
            .eraseToAnyPublisher()

        self = .pendingSending(cachedAtom: cachedAtom, updates: updates, completable: completable)
    }
}

// Throwing
public extension ResultOfUserAction {
    enum Error: Swift.Error {
        case failedToStageAction(FailedToStageAction)
        case failedToSubmitAtom(SubmitAtomError)
    }
}

public struct FailedToStageAction: Swift.Error {
    let error: Swift.Error
    let userAction: UserAction
}

// MARK: RxBlocking
public extension ResultOfUserAction {
    func toObservable() -> AnyPublisher<SubmitAtomAction, Never> {
        switch self {
        case .pendingSending(_, let updates, _):
            return updates
        case .failedToStageAction(let failedAction):
            return Fail<SubmitAtomAction, Error>.init(error: Error.failedToStageAction(failedAction))
            .eraseToAnyPublisher()
            .crashOnFailure()
        }
    }
    
    func toCompletable() -> Completable {
        switch self {
        case .pendingSending(_, _, let completable):
            return completable
        case .failedToStageAction(let failedAction):
            return Fail<SubmitAtomAction, Error>.init(error: Error.failedToStageAction(failedAction))
                .eraseToAnyPublisher()
                .ignoreOutput()
                .crashOnFailure()
        }
    }
}
