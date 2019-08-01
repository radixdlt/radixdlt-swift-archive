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

public struct NonEmptyArray<ElementInArray>:
    ArrayConvertible,
    ArrayInitializable,
    Throwing
{
    public typealias Element = ElementInArray
    // swiftlint:enable opening_brace
    
    public let elements: [Element]

    public init(unvalidated: [Element]) throws {
        if unvalidated.isEmpty {
            throw Error.arrayCannotBeEmpty
        }
        self.elements = unvalidated
    }
}

// MARK: ArrayInitializable
public extension NonEmptyArray {
    init(elements: [Element]) {
        do {
            try self.init(unvalidated: elements)
        } catch {
            fatalError("Bad value passed, got error: \(error), passed value: \(elements)")
        }
    }
}

// MARK: Throwing
public extension NonEmptyArray {
    enum Error: Swift.Error {
        case arrayCannotBeEmpty
    }
}

// MARK: Public
public extension NonEmptyArray {
    var first: Element {
        guard let first = elements.first else {
            incorrectImplementation("A non empty array should indeed contain at least one element")
        }
        return first
    }
}
