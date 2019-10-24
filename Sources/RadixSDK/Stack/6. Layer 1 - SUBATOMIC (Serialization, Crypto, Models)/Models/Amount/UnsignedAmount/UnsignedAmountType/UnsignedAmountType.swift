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

public protocol UnsignedAmountType: UnsignedInteger where Bound.Magnitude == Self.Magnitude {
    associatedtype Bound: ValueBound
    associatedtype Trait: AmountTrait
    
    init(magnitude: Magnitude, denomination: Denomination) throws
    
    static func multiplication(_ lhs: Self, _ rhs: Self) throws -> Self
    static func multiplyMagnitude(_ lhs: Magnitude, _ rhs: Magnitude) throws -> Magnitude

    static func addition(_ lhs: Self, _ rhs: Self) throws -> Self
    static func additionMagnitude(_ lhs: Magnitude, _ rhs: Magnitude) throws -> Magnitude

    static func subtraction(minuend: Self, subtrahend: Self) throws -> Self
    static func subtractionMagnitude(minuend: Magnitude, subtrahend: Magnitude) throws -> Magnitude
}

public extension UnsignedAmountType {
    static var measuredIn: Denomination { .min } // hard code to Denomination.min
    var measuredIn: Denomination { Self.measuredIn }
    
    init(magnitude: Magnitude) throws {
        try self.init(magnitude: magnitude, denomination: Self.measuredIn)
    }
}

public extension UnsignedAmountType {
    
    func multiplying(with factor: Self) throws -> Self {
        try Self.multiplication(self, factor)
    }
    
    func adding(term: Self) throws -> Self {
        try Self.addition(self, term)
    }
    
    func subtracting(subtrahend: Self) throws -> Self {
        try Self.subtraction(minuend: self, subtrahend: subtrahend)
    }
    
}
