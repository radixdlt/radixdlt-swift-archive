//
//  ConnectableObservableType_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

extension ConnectableObservableType {
    func autoConnect(numberOfSubscribers: Int) -> Observable<Element> {
        return Observable.create { observer in
            var counter = 0
            var disposables = [Disposable]()
            
            let outer = self.do(onSubscribe: {
                counter += 1
                log.verbose("autoConnect counter: \(counter) (after increment, target: \(numberOfSubscribers)")
                if counter >= numberOfSubscribers {
                    disposables.append(self.connect())
                }
            }).subscribe { (event: Event<Self.Element>) in
                switch event {
                case .next(let value):
                    observer.on(.next(value))
                case .error(let error):
                    observer.on(.error(error))
                case .completed:
                    observer.on(.completed)
                }
            }
            
            disposables.append(outer)
            
            return Disposables.create(disposables)
        }
    }
}

