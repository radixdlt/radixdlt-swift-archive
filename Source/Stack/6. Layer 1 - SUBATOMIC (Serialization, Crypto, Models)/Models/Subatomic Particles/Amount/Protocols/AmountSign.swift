//
//  AmountSign.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
