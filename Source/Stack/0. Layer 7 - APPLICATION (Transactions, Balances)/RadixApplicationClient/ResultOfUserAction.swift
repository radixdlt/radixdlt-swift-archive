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
            .filter { $0.isStatusUpdate }
            .asSingle() //.lastOrError()
            .flatMapCompletable { action in
                guard
                    case .statusOf(_, _, let statusNotification) = action
                    else { incorrectImplementation("should have filtered out just StatusUpdate case") }
                let status = statusNotification.atomStatus
                
                if status == AtomStatus.stored {
                    return Completable.empty()
                } else {
                    // TODO: map to error somewhere, instead of using raw json string
                    return Completable.error(Error.submitAtomError(underlyingReasonAsJsonString: statusNotification.dataAsJsonString))
                }
        }
        
    }
}

public extension ResultOfUserAction {
    enum Error: Swift.Error, Equatable {
        case submitAtomError(underlyingReasonAsJsonString: String)
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

extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.TraitType == SingleTrait {
    
    func flatMapCompletable(_ selector: @escaping (E) -> Completable) -> Completable {
        return self
            .asObservable()
            .flatMap { element -> Observable<Never> in
                selector(element).asObservable()
            }
            .asCompletable()
    }
    
}
