//
//  Macros.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

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
//    _ reason: String? = nil,
    _ file: String = #file,
    _ line: Int = #line
) -> Never {
    let message = "Passed bad integer value: `\(value)` to non-throwing ExpressibleByFoobarLiteral initializer, resulting in error: `\(error)`, in file: \(file), line: \(line)"
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
