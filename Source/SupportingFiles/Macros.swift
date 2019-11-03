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

internal let void: Void = ()

import SwiftyBeaver
internal let log: SwiftyBeaver.Type = {
    let log = SwiftyBeaver.self
    let console = ConsoleDestination()
    console.minLevel = .info
    log.addDestination(console)
    return log
}()

/// true when optimization is set to -Onone
var isDebug: Bool {
    return _isDebugAssertConfiguration()
}

internal func abstract(_ file: String = #file, _ line: Int = #line) -> Never {
    let message = "Override this, in file: \(file), line: \(line)"
    fatalError(message)
}

internal func implementMe(_ file: String = #file, _ line: Int = #line) -> Never {
    let message = "Implement this, in file: \(file), line: \(line)"
    fatalError(message)
}

internal func incorrectImplementationShouldAlwaysBeAble(
    to reason: String,
    _ error: Swift.Error? = nil,
    _ file: String = #file,
    _ line: Int = #line
) -> Never {
    let errorString = error.map { ", error: \($0) " } ?? ""
    incorrectImplementation("Should always be to: \(reason)\(errorString)")
}

internal func incorrectImplementation(
    _ reason: String? = nil,
    _ file: String = #file,
    _ line: Int = #line
) -> Never {
    let reasonString = reason != nil ? "`\(reason!)`" : ""
    let message = "Incorrect implementation: \(reasonString),\nIn file: \(file), line: \(line)"
    fatalError(message)
}

internal func badLiteralValue<Value>(
    _ value: Value,
    error: Swift.Error,
    _ file: String = #file,
    _ line: Int = #line
) -> Never {
    let message = "Passed bad literal value: `\(value)` to non-throwing ExpressibleByFoobarLiteral initializer, resulting in error: `\(error)`, in file: \(file), line: \(line)"
    fatalError(message)
}

internal func unexpectedlyMissedToCatch(
    error: Swift.Error,
    _ file: String = #file,
    _ line: Int = #line
) -> Never {
    incorrectImplementation("Missed error: `\(error)`, of type: `\(type(of: error))`",
        file, line
    )
}

internal func typeErasureExpects<T>(
    type anyType: Any.Type,
    toBe expectedType: T.Type,
    _ file: String = #file,
    _ line: Int = #line
    ) {
    guard (anyType as? T) != nil else {
        typeErasureExpected(instance: anyType, toBe: T.self, file, line)
    }
}

internal func typeErasureExpected<T>(
    instance incorrectTypeOfThisInstance: Any,
    toBe expectedType: T.Type,
    _ file: String = #file,
    _ line: Int = #line
) -> Never {
    incorrectImplementation(
        "Expected \(incorrectTypeOfThisInstance) to be of type `\(expectedType)`",
        file, line
    )
}

internal func castOrKill<T>(
    instance anyInstance: Any,
    toType: T.Type,
    _ file: String = #file,
    _ line: Int = #line
    ) -> T {
    guard let instance = anyInstance as? T else {
        typeErasureExpected(instance: anyInstance, toBe: T.self, file, line)
    }
    return instance
}

internal func castOrKill<T>(
    instance lhsInstance: Any,
    and rhsInstance: Any,
    toType type: T.Type,
    _ file: String = #file,
    _ line: Int = #line
) -> (lhs: T, rhs: T) {
    let lhs = castOrKill(instance: lhsInstance, toType: type, file, line)
    let rhs = castOrKill(instance: lhsInstance, toType: type, file, line)
    return (lhs: lhs, rhs: rhs)
}
