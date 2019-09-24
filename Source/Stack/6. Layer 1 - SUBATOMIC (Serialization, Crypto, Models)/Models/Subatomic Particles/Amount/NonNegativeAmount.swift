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

/// A non negative integer representing some amount, e.g. amount of tokens to transfer.
public struct NonNegativeAmount: NonNegativeAmountConvertible, Throwing {
    public typealias Magnitude = BigUnsignedInt
    public let magnitude: Magnitude
    
    public init(validated: Magnitude) {
        self.magnitude = validated
    }
}

public extension NonNegativeAmount {
    init(positive: PositiveAmount) {
        self.init(validated: positive.magnitude)
    }
    
    static func fromTransferrableTokens(
        particles: [TransferrableTokensParticle],
        amountMapper: (TransferrableTokensParticle) -> NonNegativeAmount = { $0.amount.asNonNegative }
    ) -> NonNegativeAmount {
        return reducing(particles.map(amountMapper))
    }
    
    static func reducing(_ amounts: [NonNegativeAmount]) -> NonNegativeAmount {
        return amounts.reduce(NonNegativeAmount.zero, +)
    }
}

// MARK: - Zero
public extension NonNegativeAmount {
    static var zero: NonNegativeAmount {
        return NonNegativeAmount(validated: 0)
    }
}

// MARK: - Throwing
public extension NonNegativeAmount {
    typealias Error = NonNegativeAmountError
}
