//
//  ResultOfUserAction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct ResultOfUserAction {
    private let updates: ConnectableObservable<SubmitAtomAction>
    private let completable: Completable
    public init(updates: Observable<SubmitAtomAction>) {
        
        self.updates = updates.replayAll()
        
        self.completable = updates.ofType(SubmitAtomAction.self)
            .ofType(SubmitAtomActionStatus.self)
            .takeLast(1).asSingle()
            .flatMapCompletable { submitAtomActionStatus in
                let statusNotification = submitAtomActionStatus.statusNotification
                switch statusNotification {
                case .stored: return Completable.completed()
                case .notStored(let reason):
//                    let submitAtomError: SubmitAtomError = reason.error ?? SubmitAtomError(rpcError: RPCError.unrecognizedJson(jsonString: dataAsJsonString))
                    return Completable.error(Error.failedToSubmitAtom(reason.error))
                }
            }
    }
}

public extension ResultOfUserAction {
    enum Error: Swift.Error, Equatable {
        case failedToSubmitAtom(SubmitAtomError)
    }
}

internal extension ResultOfUserAction {
    func connect() -> ResultOfUserAction {
        _ = updates.connect()
        return self
    }
    
    static var empty: ResultOfUserAction {
        implementMe()
    }
    
    static var noActiveAccountError: ResultOfUserAction {
        implementMe()
    }
}
public extension ResultOfUserAction {
    func toObservable() -> Observable<SubmitAtomAction> {
        return updates
    }
    func toCompletable() -> Completable {
        return completable
    }
}
