//
//  fatalFail.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

func fatalFail(_ message: String) -> Never {
    print(message)
    XCTFail(message)
    incorrectImplementation(message)
}

func expectNoErrorToBeThrown<Value>(
    _ file: String = #file,
    _ function: String = #function,
    _ line: Int = #line,
    tryThis: () throws -> Value
    ) -> Value {
    do {
        return try tryThis()
    } catch {
        fatalFail("Unexpected error thrown from \(file):\(function)#\(line):\n`\(error)`\n")
    }
}
