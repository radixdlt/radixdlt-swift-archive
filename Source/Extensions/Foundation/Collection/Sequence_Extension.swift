/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

public extension Sequence where Element: Hashable {
    var asSet: Set<Element> {
        return Set(self)
    }
}

public extension Array where Element: Hashable {
    enum ArrayToSetError: Swift.Error {
        case arrayContainedDuplicates
    }
    func toSet() throws -> Set<Element> {
        let set = asSet
        guard set.count == self.count else {
            throw ArrayToSetError.arrayContainedDuplicates
        }
        return set
    }
}

public extension Sequence {
    func group<Key>(by keyPath: KeyPath<Element, Key>) -> [Key: [Element]] where Key: Hashable {
        return Dictionary(grouping: self, by: {
            $0[keyPath: keyPath]
        })
    }
}

public enum Order {
    case asending
    case descending
}

public extension Sequence {
    
    func sorted<Property>(by keyPath: KeyPath<Element, Property>, order: Order = .asending) -> [Element] where Property: Comparable {
        return sorted(by: {
            let lhs = $0[keyPath: keyPath]
            let rhs = $1[keyPath: keyPath]
            switch order {
            case .asending: return lhs < rhs
            case .descending: return lhs > rhs
            }
        })
    }
}
