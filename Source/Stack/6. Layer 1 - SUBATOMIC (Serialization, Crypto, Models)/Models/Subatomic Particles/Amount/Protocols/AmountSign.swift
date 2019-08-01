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

public enum AmountSign: Int, Comparable {
  
    case negative = -1
    case zero = 0
    case positive = 1
}

// MARK: - Comparable
public extension AmountSign {
    static func < (lhs: AmountSign, rhs: AmountSign) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

// MARK: - From BigInteger
extension AmountSign {
    init(signedInt: BigSignedInt) {
        switch signedInt {
        case _ where signedInt > 0: self = .positive
        case _ where signedInt == 0: self = .zero
        case _ where signedInt < 0: self = .negative
        default: incorrectImplementation("All cases handled")
        }
    }

    init(unsignedInt: BigUnsignedInt) {
        if unsignedInt == 0 {
            self = .zero
        } else if unsignedInt > 0 {
            self = .positive
        } else {
            incorrectImplementation("Should not be negative")
        }
    }
}

public extension AmountSign {
    
    var isZero: Bool {
        guard case .zero = self else { return false }
        return true
    }
    
    var isPositive: Bool {
        guard case .positive = self else { return false }
        return true
    }
    
    var isNegative: Bool {
        guard case .negative = self else { return false }
        return true
    }
    
}
