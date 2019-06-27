//
//  ObservableType_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableType where E: LengthMeasurable {
    func ifEmpty<ErrorType>(throw errorIfEmpty: ErrorType) -> Observable<E> where ErrorType: Swift.Error {
        return asObservable().map { lengthMeasurable in
            guard let nonEmpty = lengthMeasurable.nilIfEmpty() else {
                throw errorIfEmpty
            }
            return nonEmpty
        }
    }
}

public extension ObservableType where E: Sequence {
    func first<ErrorType>(ifEmptyThrow errorIfEmpty: ErrorType) -> Observable<E.Element> where ErrorType: Swift.Error {
        return asObservable().map { sequence in
            let array = [E.Element](sequence)
            guard let nonEmpty = array.nilIfEmpty() else {
                throw errorIfEmpty
            }
            return nonEmpty[0]
        }
    }
}
