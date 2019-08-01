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

// swiftlint:disable opening_brace

public struct NonEmptySet<ElementInSet>:
    ArrayConvertible,
    Throwing,
    Hashable,
    ExpressibleByArrayLiteral
where
    ElementInSet: Hashable
{
    // swiftlint:enable opening_brace
    
    private let set: Set<ElementInSet>
    
    public init(set: Set<ElementInSet>) throws {
        if set.isEmpty {
            throw Error.setCannotBeEmpty
        }
        self.set = set
    }
}

extension Array where Element: Hashable {
    func containsDuplicates() -> Bool {
        let numberOfElementsInArray = count
        let numberOfElementsInSet = Set(self).count
        let containsDuplicates = numberOfElementsInSet < numberOfElementsInArray
        return containsDuplicates
    }
}

public extension NonEmptySet {
    
    init(array: [Element]) throws {
        guard !array.containsDuplicates() else {
            throw Error.cannotCreateSetFromArrayThatContainsDuplicates
        }
        try self.init(set: array.asSet)
    }
    
    init(single: ElementInSet) {
        self.set = Set([single])
    }
}

// MARK: - ExpressibleByArrayLiteral
public extension NonEmptySet {
    
    init(arrayLiteral elements: Element...) {
        do {
            try self.init(set: Set(elements))
        } catch {
            fatalError("Passed bad array: \(elements), error: \(error)")
        }
    }
}

public extension NonEmptySet {
    typealias Element = ElementInSet
    var elements: [Element] { return set.asArray }
}

public extension NonEmptySet {
    enum Error: Swift.Error {
        case setCannotBeEmpty
        case cannotCreateSetFromArrayThatContainsDuplicates
    }
}

public extension ArrayConvertible {
    func randomElement() -> Element? {
        guard !isEmpty else { return nil }
        let randomInt = Int.random(in: 0..<count)
        let randomIndex = self.index(self.startIndex, offsetBy: randomInt)
        return self[randomIndex]
    }
}

public extension NonEmptySet {
    func randomElement() -> Element {
        let randomInt = Int.random(in: 0..<count)
        let randomIndex = self.index(elements.startIndex, offsetBy: randomInt)
        return elements[randomIndex]
    }
}
