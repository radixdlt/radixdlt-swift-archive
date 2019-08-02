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

public struct SignedAmount: Amount, SignedNumeric {
    
    public typealias Magnitude = BigSignedInt
    
    public let magnitude: Magnitude
    
    public init(validated: Magnitude) {
        self.magnitude = validated
    }
    
    public init(bigUnsignedInt: BigUnsignedInt) {
        let selfMagnitude = Magnitude.init(sign: .plus, magnitude: bigUnsignedInt)
        self.init(validated: selfMagnitude)
    }
    
    public init<NNA>(nonNegative: NNA) where NNA: NonNegativeAmountConvertible {
        self.init(bigUnsignedInt: nonNegative.magnitude)
    }
}

// MARK: - Amount
public extension SignedAmount {
    func negated() -> SignedAmount {
        return SignedAmount(validated: -1 * magnitude)
    }
    
    var abs: NonNegativeAmount {
        return NonNegativeAmount(validated: NonNegativeAmount.Magnitude(Swift.abs(magnitude)))
    }
    
    var sign: AmountSign {
        return AmountSign(signedInt: magnitude)
    }
}

// MARK: - Zero
public extension SignedAmount {
    static var zero: SignedAmount {
        return SignedAmount(validated: 0)
    }
}

// MARK: - From Amount
public extension SignedAmount {
    init<A>(amount: A) where A: Amount {
        self.init(validated: Magnitude(amount.magnitude))
    }
}
