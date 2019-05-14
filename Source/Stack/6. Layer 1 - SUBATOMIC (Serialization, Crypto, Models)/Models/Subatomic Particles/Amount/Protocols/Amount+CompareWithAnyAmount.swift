//
//  Amount+CompareWithAnyAmount.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// MARK: - Public Operator
public func == <A, B>(lhs: A, rhs: B) -> Bool where A: Amount, B: Amount {
    switch (lhs.amountAndSign, rhs.amountAndSign) {
    case (.zero, .zero): return true
    case (.positive(let lhsAmount), .positive(let rhsAmount)): return lhsAmount == rhsAmount
    case (.negative(let lhsAmount), .negative(let rhsAmount)): return lhsAmount == rhsAmount
    default: return false
    }
}

public func > <A, B>(lhs: A, rhs: B) -> Bool where A: Amount, B: Amount {
    return notEqualsCompare(lhs, rhs, >, >)
}

public func < <A, B>(lhs: A, rhs: B) -> Bool where A: Amount, B: Amount {
    return notEqualsCompare(lhs, rhs, <, <)
}

public func <= <A, B>(lhs: A, rhs: B) -> Bool where A: Amount, B: Amount {
    return lhs == rhs || lhs < rhs
}

public func >= <A, B>(lhs: A, rhs: B) -> Bool where A: Amount, B: Amount {
    return lhs == rhs || lhs > rhs
}

// MARK: - Private
private func notEqualsCompare <A, B>(
    _ lhs: A,
    _ rhs: B,
    _ comparePositveMagnitudes: (BigUnsignedInt, BigUnsignedInt) -> Bool,
    _ compareSign: (AmountSign, AmountSign) -> Bool
    ) -> Bool where A: Amount, B: Amount {
    
    switch (lhs.amountAndSign, rhs.amountAndSign) {
    case (.positive(let lhsAmount), .positive(let rhsAmount)):
        return comparePositveMagnitudes(lhsAmount, rhsAmount)
    case (.negative(let lhsAmount), .negative(let rhsAmount)):
        return (lhsAmount != rhsAmount) && !comparePositveMagnitudes(lhsAmount, rhsAmount)
    default: break
    }
    return compareSign(lhs.sign, rhs.sign)
}
