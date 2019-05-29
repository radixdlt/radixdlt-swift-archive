//
//  Range+BinaryInteger+Span.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Range where Element: BinaryInteger {
    var span: Element {
        // + 1 to be inclusive in both ends
        return upperBound - lowerBound + 1
    }
}
