//
//  String+Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension String {
    /// stringToFind must be at least 1 character.
    func countInstances(of stringToFind: String, options: String.CompareOptions = []) -> UInt {
        assert(!stringToFind.isEmpty)
        var count: UInt = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: stringToFind, options: options, range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
}
