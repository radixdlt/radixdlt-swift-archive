//
//  ObservableConvertibleType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt

extension ObservableConvertibleType {
    func cache() -> Observable<Element> {
        return self.asObservable().share(replay: 1, scope: .forever)
    }

    func firstOrError() -> Single<Element> {
        return self.asObservable().elementAt(0).take(1).asSingle()
    }
    
    func lastOrError() -> Single<Element> {
        // `count` is part of `RxSwiftExt`
        return asObservable().count().flatMap {
            return self.asObservable().elementAt($0 - 1)
        }.take(1).asSingle()
    }
    
    func flatMapIterable<Other>(_ selector: @escaping (Element) -> [Other]) -> Observable<Other> {
        return asObservable().flatMap { (element: Element) -> Observable<Other> in
            return Observable.from(selector(element))
        }
    }
}
