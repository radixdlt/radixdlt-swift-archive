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

public protocol ValueBound where Magnitude.Magnitude == Magnitude {
    associatedtype Magnitude: MagnitudeType
    static var isSigned: Bool { get }
    
    /// Greatest possible magnitude measured in the smallest possible `Denomination` (`Denomination.minExponent`)
    static var greatestFiniteMagnitude: Magnitude { get }
    
    /// Smallest possible magnitude measured in the smallest possible `Denomination` (`Denomination.minExponent`)
    static var leastNormalMagnitude: Magnitude { get }
    
    static func contains(value: Magnitude) throws
}

public extension ValueBound {
    static var isSigned: Bool { Magnitude.isSigned }
 
    static func contains(value: Magnitude) throws {
        if value > Self.greatestFiniteMagnitude { throw AmountError.valueTooBig }
        if value < Self.leastNormalMagnitude { throw AmountError.valueTooSmall }
        // all is well
    }
    
    static var leastNormalMagnitude: Magnitude { 0 }
}

public enum AmountError: Swift.Error, Equatable {
    case valueTooBig
    case valueTooSmall
    case valueCannotBeNegative
}
