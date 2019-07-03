//
//  ObservableType_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
    func flatMapCompletable(_ selector: @escaping (Element) -> Completable) -> Completable {
        return self.asSingle().flatMapCompletable(selector)
    }
    
    func flatMapSingle<Other>(_ selector: @escaping (Element) -> Single<Other>) -> Observable<Other> {
        return self.asSingle().flatMap(selector).asObservable()
    }

    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}

extension ObservableType where Element == Void {
    func flatMapCompletableVoid(_ selector: @escaping () -> Completable) -> Completable {
        return self.asSingle().flatMapCompletableVoid(selector)
    }
}
