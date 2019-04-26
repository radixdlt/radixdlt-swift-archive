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
