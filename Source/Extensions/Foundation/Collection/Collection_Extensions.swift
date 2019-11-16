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

internal enum ZeroOneTwoAndMany<Element> {
    case zero
    case one(single: Element)
    case two(first: Element, secondAndLast: Element)
    case many(head: Element, tail: [Element])
}

internal extension Collection {
    
    var countedElementsZeroOneTwoAndMany: ZeroOneTwoAndMany<Element> {
        guard !isEmpty else { return .zero }

        let firstElement = first!

        guard count > 1 else { return .one(single: firstElement) }

        let tail = [Element](self.dropFirst())

        guard count > 2 else {
            return .two(first: firstElement, secondAndLast: tail.first!)
        }

        return .many(head: firstElement, tail: tail)
    }
}

internal enum OneTwoAndMany<Element> {
    case one(single: Element)
    case two(first: Element, secondAndLast: Element)
    case many(head: Element, tail: [Element])
}

extension Collection where Self: NonEmptyCollection {
    var countedElementsOneTwoAndMany: OneTwoAndMany<Element> {
        guard count > 1 else { return .one(single: first) }
        
        if count == 2 {
            return .two(first: first, secondAndLast: last)
        } else {
            return .many(head: first, tail: [Element](self.dropFirst()))
        }
    }
}
