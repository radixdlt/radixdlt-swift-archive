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

public extension Decimal {
    enum Error: Int, Swift.Error, Equatable {
        case divideByZero, lossOfPrecision, overflow, underflow, unknown
    }
}

public extension Decimal.Error {
    init?(exception: NSDecimalNumber.CalculationError) {
        switch exception {
        case .noError: return nil
        case .divideByZero: self = .divideByZero
        case .lossOfPrecision: self = .lossOfPrecision
        case .overflow: self = .overflow
        case .underflow: self = .underflow
        @unknown default: self = .unknown
        }
    }
}

internal extension NumberFormatter {
    static var `default`: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ""
        formatter.locale = Locale.current
        return formatter
    }
}

public extension Decimal {
    
    static func ten(
        toThePowerOf exponent: Int,
        roundingMode: NSDecimalNumber.RoundingMode = .plain
    ) throws -> Decimal {
        
        return try pow(base: 10, exponent: exponent, roundingMode: roundingMode)
    }
    
    static func pow(
        base: Decimal,
        exponent: Int,
        roundingMode: NSDecimalNumber.RoundingMode = .plain
    ) throws -> Decimal {
        
        if exponent == 0 { return Decimal(1) }
        if exponent == 1 { return base }
        
        var result = Decimal()
        var base = base
        
        let exception = NSDecimalPower(&result, &base, abs(exponent), roundingMode)
        
        if let error = Error(exception: exception) {
            throw error
        }
        
        if exponent > 1 {
            return result
        } else if exponent < 0 {
            return try Self.divide(nominator: 1, denominator: result)
        } else { incorrectImplementation("Base case where exponent=\(exponent) should have been earlier.") }
    }
    
    static func divide(
        nominator: Decimal,
        denominator: Decimal,
        roundingMode: NSDecimalNumber.RoundingMode = .plain
    ) throws -> Decimal {
        
        return try doOperation(lhs: nominator, rhs: denominator, roundingMode: roundingMode, NSDecimalDivide)
    }
}

private extension Decimal {
    
    static func doOperation(
        lhs: Decimal,
        rhs: Decimal,
        roundingMode: NSDecimalNumber.RoundingMode = .plain,
        _ operation: (UnsafeMutablePointer<Decimal>, UnsafePointer<Decimal>, UnsafePointer<Decimal>, NSDecimalNumber.RoundingMode) -> NSDecimalNumber.CalculationError,
        _ resultHandler: (Decimal) -> Decimal = { $0 }
    ) throws -> Decimal {
        
        var result = Decimal()
        var lhs = lhs
        var rhs = rhs
        
        let exception = operation(&result, &lhs, &rhs, roundingMode)
        
        if let error = Error(exception: exception) {
            throw error
        }
        
        return resultHandler(result)
    }
}
