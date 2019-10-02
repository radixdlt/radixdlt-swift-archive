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

//public struct PositiveAmount: Comparable, CustomStringConvertible {
//
//    /// The use can never spend negative amounts, nor can she create a token with a negative supply, thus safe to bound to at least `NonNegativeAmount`. But since the zero amount (`0`) is not so relevant, we skip support for that.
//    public let amountMeasuredInAtto: PositiveAmount
//
//    /// `amount` is a non negative integer type, we do not allow dealing with decimal values due to lack of `BigDecimal` in Swift. Using Swift standard library (`Foundation`)'s number type `Decimal` does not provide us with enough precision.
//    ///
//    public init(positiveAmount nonConvertedAmount: PositiveAmount, denomination from: Denomination) {
//        self.amountMeasuredInAtto = Self.convertToAtto(amount: nonConvertedAmount, from: from)
//    }
//}
//

