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

public protocol DSONArrayConvertible: DSONEncodable, ArrayConvertible {
    func dsonEncodeElement(_ element: Element, output: DSONOutput) throws -> DSON
}

public extension DSONArrayConvertible where Element: DSONEncodable {
    func dsonEncodeElement(_ element: Element, output: DSONOutput) throws -> DSON {
        return try element.toDSON(output: output)
    }
}

// MARK: - DSONEncodable
public extension DSONArrayConvertible where Element: DSONEncodable {
    func toDSON(output: DSONOutput) throws -> DSON {
        return try [Element](self).toDSON(output: output)
    }
}

extension Array: DSONEncodable where Element: DSONEncodable {
    public func toDSON(output: DSONOutput) throws -> DSON {
        var array = try count.encode() + self.flatMap { try $0.toDSON(output: output) }
        // Bit mask for CBOR major type 4 (array): 0b100 << 1 <=> 0b1000
        array[0] |= 0b100_00000
        return array.asData
    }
}

