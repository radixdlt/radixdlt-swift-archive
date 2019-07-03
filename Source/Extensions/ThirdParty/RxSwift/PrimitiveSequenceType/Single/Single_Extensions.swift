//
//  Single_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

extension PrimitiveSequenceType where Self: ObservableConvertibleType, Self.Trait == SingleTrait {
    
    func flatMapObservable<Other>(_ selector: @escaping (Element) throws -> Observable<Other>) -> Observable<Other> {
        return self.asObservable().flatMap(selector)
    }
    
    func flatMapCompletable(_ selector: @escaping (Element) -> Completable) -> Completable {
        return self
            .asObservable()
            .flatMap { element -> Observable<Never> in
                selector(element).asObservable()
            }
            .asCompletable()
    }
    
    func flatMapCompletableVoid(_ selector: @escaping () -> Completable) -> Completable {
        return self
            .asObservable().mapToVoid()
            .flatMap { _ -> Observable<Never> in
                selector().asObservable()
            }
            .asCompletable()
    }
    
}
