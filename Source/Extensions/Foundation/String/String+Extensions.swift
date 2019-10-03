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
    
    enum Case {
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
    
    init(data: Data, encodingForced: String.Encoding = .default) {
        guard let string = String(data: data, encoding: encodingForced) else {
            incorrectImplementationShouldAlwaysBeAble(to: "Get initialise a `String` from `Data`")
        }
        self = string
    }
    
    func toData(encodingForced: String.Encoding = .default) -> Data {
        guard let encodedData = self.data(using: encodingForced) else {
            incorrectImplementationShouldAlwaysBeAble(to: "Encode a `String` into `Data`")
        }
        return encodedData
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
