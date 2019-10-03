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
@testable import RadixSDK

//// MARK: - ExpressibleByIntegerLiteral
//extension Granularity: ExpressibleByIntegerLiteral {}
//public extension Granularity {
//    init(integerLiteral int: UInt) {
//        do {
//            try self.init(int: int)
//        } catch {
//            fatalError("Passed bad value, error: \(error), value: \(int)")
//        }
//    }
//}

// MARK: - ExpressibleByIntegerLiteral
extension EUID: ExpressibleByIntegerLiteral {}
public extension EUID {
    init(integerLiteral int: Int) {
        do {
            try self.init(int: int)
        } catch {
            fatalError("Passed bad value, error: \(error), value: \(int)")
        }
    }
}

//// MARK: - ExpressibleByIntegerLiteral
//extension Supply: ExpressibleByIntegerLiteral {}
//public extension Supply {
//    init(integerLiteral unvalidated: Int) {
//        do {
//            let nonNegativeAmount = try NonNegativeAmount(integer: unvalidated)
//            try self.init(nonNegativeAmount: nonNegativeAmount)
//        } catch {
//            badLiteralValue(unvalidated, error: error)
//        }
//    }
//}
//
//
//// MARK: - ExpressibleByIntegerLiteral
//extension PositiveSupply: ExpressibleByIntegerLiteral {}
//public extension PositiveSupply {
//    init(integerLiteral unvalidated: Int) {
//        do {
//            let amount = try PositiveAmount(integer: unvalidated)
//            try self.init(amount: amount)
//        } catch {
//            badLiteralValue(unvalidated, error: error)
//        }
//    }
//}
