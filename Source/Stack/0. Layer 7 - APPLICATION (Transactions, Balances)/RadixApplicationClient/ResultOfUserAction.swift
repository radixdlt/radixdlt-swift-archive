//
//  ResultOfUserAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import RxBlocking
import RxSwiftExt

public enum ResultOfUserAction: Throwing {
    
    case pendingSending(
        /// Ugly hack to retain this observable
        cachedAtom: Single<SignedAtom>,
        updates: ConnectableObservable<SubmitAtomAction>,
        completable: Completable
    )
    
    case failedToStageAction(FailedToStageAction)
}

// MARK: Convenience Init
public extension ResultOfUserAction {

    init(updates: Observable<SubmitAtomAction>, cachedAtom: Single<SignedAtom>, autoConnect: ((Disposable) -> Void)?) {
        let replayedUpdates = updates.replayAll()
        
        let completable = updates.ofType(SubmitAtomActionStatus.self)
            .lastOrError()
            .flatMapCompletable { submitAtomActionStatus in
                let statusNotification = submitAtomActionStatus.statusNotification
                switch statusNotification {
                case .stored: return Completable.completed()
                case .notStored(let reason):
                    log.warning("Not stored, reason: \(reason)")
                    return Completable.error(Error.failedToSubmitAtom(reason.error))
                }
            }
        
        self = .pendingSending(cachedAtom: cachedAtom, updates: replayedUpdates, completable: completable)
        
        if let autoConnect = autoConnect {
            autoConnect(replayedUpdates.connect())
        }
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
    func toObservable() -> Observable<SubmitAtomAction> {
        switch self {
        case .pendingSending(_, let updates, _):
            return updates
        case .failedToStageAction(let failedAction):
            return Observable<SubmitAtomAction>.error(Error.failedToStageAction(failedAction))
        }
    }
    
    func toCompletable() -> Completable {
        switch self {
        case .pendingSending(_, _, let completable):
            return completable
        case .failedToStageAction(let failedAction):
            return Completable.error(Error.failedToStageAction(failedAction))
        }
    }
    
    // Returns a bool marking if the action was successfully completed within the provided time period if any timeout was provided
    // if no `timeout` was provided, then the bool just marks if the action was successfull or not in general.
    func blockUntilComplete(timeout: TimeInterval? = nil) -> Bool {
        switch toCompletable().toBlocking(timeout: timeout).materialize() {
        case .completed: return true
        case .failed: return false
        }
    }
}
