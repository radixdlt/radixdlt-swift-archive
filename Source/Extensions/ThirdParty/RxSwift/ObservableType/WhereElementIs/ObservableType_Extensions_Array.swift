//
//  ObservableType_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableType where Element: LengthMeasurable {
    func ifEmpty<ErrorType>(throw errorIfEmpty: ErrorType) -> Observable<Element> where ErrorType: Swift.Error {
        return asObservable().map { lengthMeasurable in
            guard let nonEmpty = lengthMeasurable.nilIfEmpty() else {
                throw errorIfEmpty
            }
            return nonEmpty
        }
    }
}

public extension ObservableType where Element: Sequence {
    func first<ErrorType>(ifEmptyThrow errorIfEmpty: ErrorType) -> Observable<Element.Element> where ErrorType: Swift.Error {
        return asObservable().map { sequence in
            let array = [Element.Element](sequence)
            guard let nonEmpty = array.nilIfEmpty() else {
                throw errorIfEmpty
            }
            return nonEmpty[0]
        }
    }
}
