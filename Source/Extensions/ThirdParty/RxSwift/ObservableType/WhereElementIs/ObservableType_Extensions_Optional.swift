//
//  ObservableType+FilterNil.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableType where Element: OptionalType {

//    func replaceNilWith(_ valueOnNil: Element.Wrapped) -> Observable<Element.Wrapped> {
//        return self.map { element -> Element.Wrapped in
//            guard let value = element.value else {
//                return valueOnNil
//            }
//            return value
//        }
//    }
    
    func ifNilReturnEmpty() -> Observable<Element.Wrapped> {
        return self.flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return Observable<Element.Wrapped>.empty()
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
    
    func ifNil(throw error: Error) -> Observable<Element.Wrapped> {
        return self.flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                return Observable<Element.Wrapped>.error(error)
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
    
    func ifNilKill(_ message: String) -> Observable<Element.Wrapped> {
        return self.flatMap { element -> Observable<Element.Wrapped> in
            guard let value = element.value else {
                incorrectImplementation(message)
            }
            return Observable<Element.Wrapped>.just(value)
        }
    }
}
