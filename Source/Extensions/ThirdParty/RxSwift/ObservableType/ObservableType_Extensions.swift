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

extension ObservableType where E: PotentiallyRequestIdentifiable {
    func ifNeededFilterOnRequestId(_ requestId: Int?) -> Observable<E> {
        
        guard let requestId = requestId else {
            return self.asObservable()
        }
        
        // If response contains id, filter on it
        return self.asObservable().map { element -> E? in
            if let elementRequestId = element.requestIdIfPresent {
                guard elementRequestId == requestId else {
                    log.warning("Request id mismatch (`\(elementRequestId)` != `\(requestId)`), thus omitting/ignoring element: \(element)")
                    return nil
                }
            }
            return element
        }.filterNil()
    }
}
