//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
