//
//  String+Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum Direction {
    case leading, trailing
}

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
    
    func removingSubrange(_ bounds: Range<Index>) -> String {
        var mutable = self
        mutable.removeSubrange(bounds)
        return mutable
    }

    func changeCaseIfNeeded(to case: String.Case?) -> String {
        switch `case` {
        case .none: return self
        case .upper?: return uppercased()
        case .lower?: return lowercased()
        }
    }
    
    public enum Case {
        case upper, lower
    }
    
    var reverse: String {
        return String(reversed())
    }
    
    mutating func trim(character toRemove: Character, caseInsensitive: Bool = false, direction: Direction = .leading) {
        self = trimming(character: toRemove, caseInsensitive: caseInsensitive, direction: direction)
    }
    
    func trimming(character toRemove: Character, caseInsensitive: Bool = false, direction: Direction = .leading) -> String {
        
        let dropIfNeeded = { (character: Character) -> Bool in
            guard caseInsensitive else {
                return character == toRemove
            }
            let uppercase = Character(String(toRemove).uppercased())
            let lowercase = Character(String(toRemove).lowercased())
            return character == uppercase || character == lowercase
        }
        
        switch direction {
        case .leading: return String(drop(while: { dropIfNeeded($0) }))
        case .trailing:
            return reverse.trimming(character: toRemove, direction: .leading).reverse
        }
    }
}
