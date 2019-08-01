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

// swiftlint:disable colon

/// An Array-like type
public protocol ArrayConvertible:
    LengthMeasurable,
    Collection {
// swiftlint:enable colon
    var elements: [Element] { get }
}

// MARK: - LengthMeasurable Conformance
public extension ArrayConvertible {
    var length: Int {
        return elements.count
    }
}

// MARK: - Collection
public extension ArrayConvertible {
    typealias ArrayIndex = Array<Element>.Index
    
    var startIndex: ArrayIndex {
        return elements.startIndex
    }
    
    var endIndex: ArrayIndex {
        return elements.endIndex
    }
    
    subscript(position: ArrayIndex) -> Element {
        return elements[position]
    }
    
    func index(after index: ArrayIndex) -> ArrayIndex {
        return elements.index(after: index)
    }
}
