//
//  Range+BinaryInteger+Span.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Range where Element: BinaryInteger {
    /// Returns `upperBound - lowerBound`, thus this is NOT the same thing as the number of elements in this range.
    var stride: Element {
        return upperBound - lowerBound
    }
}
