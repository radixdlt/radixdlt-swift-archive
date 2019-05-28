//
//  SignedInteger+CompareUnsigned.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

extension SignedInteger where Self: FixedWidthInteger {
    
    /// Compares two signed integers numerically treating the values as unsigned.
    ///
    /// Swift equivalence of Java's [compareUnsigned][1]
    ///
    /// [1]: https://docs.oracle.com/javase/8/docs/api/java/lang/Long.html#compareUnsigned-long-long-
    ///
    static var areInIncreasingOrderUnsigned: ((Self, Self) -> Bool) {
        
        func mapToUnsigned(_ signed: Self) -> Self {
            let (result, _) = signed.addingReportingOverflow(Self.min)
            return result
        }
        
        return { (lhs: Self, rhs: Self) -> Bool in
            return mapToUnsigned(lhs) < mapToUnsigned(rhs)
        }
    }

}
