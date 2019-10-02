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

public extension UnsignedAmountType {
    static var isSigned: Bool { Bound.isSigned }
    
    init() {
        implementMe()
    }
    
    init<T>(_ source: T) where T : BinaryInteger {
        implementMe()
    }
    
    // Optional?
    init<T>(_ source: T) where T : BinaryFloatingPoint {
        implementMe()
    }
    
    init<T>(clamping source: T) where T : BinaryInteger {
        implementMe()
    }
    
    init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        implementMe()
    }
    
    init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        implementMe()
    }
    
    var words: Words { magnitude.words }
    
    var bitWidth: Int { magnitude.bitWidth }
    
    var trailingZeroBitCount: Int { magnitude.trailingZeroBitCount }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        implementMe()
    }
    
    static func /= (lhs: inout Self, rhs: Self) {
        implementMe()
    }
    
    static func % (lhs: Self, rhs: Self) -> Self {
        implementMe()
    }
    
    static func %= (lhs: inout Self, rhs: Self) {
        implementMe()
    }
    
    static func &= (lhs: inout Self, rhs: Self) {
        implementMe()
    }
    
    static func |= (lhs: inout Self, rhs: Self) {
        implementMe()
    }
    
    static func ^= (lhs: inout Self, rhs: Self) {
        implementMe()
    }
    
    prefix static func ~ (x: Self) -> Self {
        implementMe()
    }
    
    static func >>= <RHS>(lhs: inout Self, rhs: RHS) where RHS : BinaryInteger {
        implementMe()
    }
    
    static func <<= <RHS>(lhs: inout Self, rhs: RHS) where RHS : BinaryInteger {
        implementMe()
    }
    
    init(integerLiteral value: IntegerLiteralType) {
        implementMe()
    }
}
