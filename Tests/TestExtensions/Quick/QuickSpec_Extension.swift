//
//  QuickSpec_Extension.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Nimble
import Quick

func beNotNil<T>() -> Predicate<T> {
    return Predicate.simpleNilable("be not nil") { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return PredicateStatus(bool: actualValue != nil)
    }
}

func throwError<E>(type: E.Type, closure: @escaping ((E) -> Void)) -> Nimble.Predicate<Any> where E: Swift.Error {
    return throwError { (anyError: Error) in
        guard let error = anyError as? E else {
            return fail("Incorrect error type, expected '\(type)' but got \(anyError)")
        }
        closure(error)
    }
}
