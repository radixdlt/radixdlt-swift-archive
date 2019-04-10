//
//  BinaryInteger+RoundToMultipleOF.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable all

// From: https://forums.swift.org/t/rounding-numbers-up-down-to-nearest-multiple-and-power/15547/4?u=sajjon
extension BinaryInteger {
    func roundedTowardZero(toMultipleOf m: Self) -> Self {
        return self - (self % m)
    }
    
    func roundedAwayFromZero(toMultipleOf m: Self) -> Self {
        let x = self.roundedTowardZero(toMultipleOf: m)
        if x == self { return x }
        return (m.signum() == self.signum()) ? (x + m) : (x - m)
    }
    
    func roundedDown(toMultipleOf m: Self) -> Self {
        return (self < 0) ? self.roundedAwayFromZero(toMultipleOf: m)
            : self.roundedTowardZero(toMultipleOf: m)
    }
    
    func roundedUp(toMultipleOf m: Self) -> Self {
        return (self > 0) ? self.roundedAwayFromZero(toMultipleOf: m)
            : self.roundedTowardZero(toMultipleOf: m)
    }
}

// swiftlint:enable all
