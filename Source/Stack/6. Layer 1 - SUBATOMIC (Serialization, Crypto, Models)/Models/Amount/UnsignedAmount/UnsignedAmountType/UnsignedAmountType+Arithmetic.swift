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

// MARK: - Numeric Operators
public extension UnsignedAmountType {
    
    /// Multiplies two values and produces their product.
    static func multiplication(_ lhs: Self, _ rhs: Self) throws -> Self {
        try calculate(lhs, rhs, operation: *)
    }
    
    static func multiplyMagnitude(_ lhs: Magnitude, _ rhs: Magnitude) throws -> Magnitude {
        try calculateMagnitude(lhs, rhs, operation: *)
    }

    /// Multiplies two values and produces their product.
    static func * (lhs: Self, rhs: Self) -> Self {
        calculateOrCrash(lhs, rhs, multiplication)
    }
        
    /// Adds two values and produces their sum.
    static func addition(_ lhs: Self, _ rhs: Self) throws -> Self {
        try calculate(lhs, rhs, operation: +)
    }
    
    static func additionMagnitude(_ lhs: Magnitude, _ rhs: Magnitude) throws -> Magnitude {
        try calculateMagnitude(lhs, rhs, operation: +)
    }
        
    /// Adds two values and produces their sum.
    static func + (lhs: Self, rhs: Self) -> Self {
        calculateOrCrash(lhs, rhs, addition)
    }
    
    /// Subtracts one value from another and produces their difference.
    static func subtraction(minuend: Self, subtrahend: Self) throws -> Self {
        try calculate(minuend, subtrahend,
                      willOverflowIf: subtrahend > minuend,
                      operation: -)
    }
    
    static func subtractionMagnitude(minuend: Magnitude, subtrahend: Magnitude) throws -> Magnitude {
        try calculateMagnitude(minuend, subtrahend,
                               willOverflowIf: subtrahend > minuend,
                               operation: -)
    }
    
    /// Subtracts one value from another and produces their difference.
    static func - (lhs: Self, rhs: Self) -> Self {
        calculateOrCrash(lhs, rhs, subtraction)
    }
}

 // swiftlint:disable shorthand_operator

// MARK: - Numeric Operators Inout
public extension UnsignedAmountType {
    
    /// Adds two values and stores the result in the left-hand-side variable.
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    
    /// Subtracts the second value from the first and stores the difference in the left-hand-side variable.
    static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    
    /// Multiplies two values and stores the result in the left-hand-side variable.
    static func *= (lhs: inout Self, rhs: Self) {
        lhs = lhs * rhs
    }
    
    static func / (lhs: Self, rhs: Self) -> Self {
        return calculateOrCrash(lhs, rhs, /)
    }
    
    static func /= (lhs: inout Self, rhs: Self) {
        lhs = lhs / rhs
    }
    
    static func % (lhs: Self, rhs: Self) -> Self {
        return calculateOrCrash(lhs, rhs, %)
    }
    
    static func %= (lhs: inout Self, rhs: Self) {
        lhs = lhs % rhs
    }
    
    static func & (lhs: Self, rhs: Self) -> Self {
        return calculateOrCrash(lhs, rhs, &)
    }
    
    static func &= (lhs: inout Self, rhs: Self) {
        lhs = lhs & rhs
    }
    
    static func | (lhs: Self, rhs: Self) -> Self {
        return calculateOrCrash(lhs, rhs, |)
    }
    
    static func |= (lhs: inout Self, rhs: Self) {
        lhs = lhs | rhs
    }
    
    static func ^ (lhs: Self, rhs: Self) -> Self {
        return calculateOrCrash(lhs, rhs, ^)
    }
    
    static func ^= (lhs: inout Self, rhs: Self) {
        lhs = lhs ^ rhs
    }
    
    prefix static func ~ (x: Self) -> Self {
        let tildeMagnitude: Magnitude = ~x.magnitude
        do {
            return try self.init(magnitude: tildeMagnitude)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Error performing `~`, error: \(error)")
        }
    }
    
    static func >> <RHS>(lhs: Self, rhs: RHS) -> Self where RHS: BinaryInteger {
        return calculateOrCrashOtherBinaryInteger(lhs, rhs, >>)
    }
    
    static func >>= <RHS>(lhs: inout Self, rhs: RHS) where RHS: BinaryInteger {
        lhs = lhs >> rhs
    }
    
    static func << <RHS>(lhs: Self, rhs: RHS) -> Self where RHS: BinaryInteger {
        return calculateOrCrashOtherBinaryInteger(lhs, rhs, <<)
    }
    
    static func <<= <RHS>(lhs: inout Self, rhs: RHS) where RHS: BinaryInteger {
        lhs = lhs << rhs
    }
}

// swiftlint:enable shorthand_operator

// MARK: - Private Helper
private extension UnsignedAmountType {
    
    static func calculateOrCrash(_ lhs: Self, _ rhs: Self, _ function: (Self, Self) throws -> Self) -> Self {
        do {
            return try function(lhs, rhs)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Perofmr arithmetic between (lhs: \(lhs), rhs: \(rhs)), error: \(error)")
        }
    }
    
    static func calculateOrCrashOtherBinaryInteger<RHS>(_ lhs: Self, _ rhs: RHS, _ function: (Self, RHS) throws -> Self) -> Self where RHS: BinaryInteger {
        do {
            return try function(lhs, rhs)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Perofmr arithmetic between (lhs: \(lhs), rhs: \(rhs)), error: \(error)")
        }
    }
    
    static func calculate(
        _ lhs: Self,
        _ rhs: Self,
        willOverflowIf overflowCheck: @autoclosure () -> Bool = { false }(),
        operation: @escaping (Magnitude, Magnitude) -> Magnitude
    ) throws -> Self {
        precondition(overflowCheck() == false, "Overflow")
        let result = try calculateMagnitude(lhs.magnitude, rhs.magnitude, operation: operation)
        return try Self(magnitude: result)
    }
    
    static func calculateMagnitude(
        _ lhs: Magnitude,
        _ rhs: Magnitude,
        willOverflowIf overflowCheck: @autoclosure () -> Bool = { false }(),
        operation: (Magnitude, Magnitude) -> Magnitude
    ) throws -> Magnitude {
        precondition(overflowCheck() == false, "Overflow")
        let result = operation(lhs, rhs)
        try Bound.contains(value: result)
        return result
    }
    
}

// MARK: - Comparable
public extension UnsignedAmountType {
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.magnitude < rhs.magnitude
    }
    static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.magnitude > rhs.magnitude
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.magnitude == rhs.magnitude
    }
}

