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
import XCTest


func XCTAssertNotThrowsAndEqual<Result>(
    _ codeThatShouldNotThrow: @autoclosure () throws -> Result,
    _ expectedValue: Result,
    _ message: String = ""
) where Result: Equatable {
    guard let result = XCTAssertNotThrows(
        try codeThatShouldNotThrow()
    ) else { return XCTFail("Unable to assert equality since expression threw error") }
    XCTAssertEqual(result, expectedValue, message)
}


@discardableResult
func XCTAssertNotThrows<Result>(_ codeThatShouldNotThrow: @autoclosure () throws -> Result) -> Result? {
    do {
        return try codeThatShouldNotThrow()
    } catch {
        XCTFail("Unexpected error: \(error)")
        return nil
    }
}

func XCTAssertNotThrows<Result>(
    _ codeThatShouldNotThrow: @autoclosure () throws -> Result,
    innerAssert: (Result) -> Void
) {
    guard let result = XCTAssertNotThrows(try codeThatShouldNotThrow()) else { return }
    innerAssert(result)
}


func XCTAssertThrowsSpecificError<ReturnValue, ExpectedError>(
    _ codeThatThrows: @autoclosure () throws -> ReturnValue,
    _ error: ExpectedError,
    _ message: String = ""
) where ExpectedError: Swift.Error & Equatable {
    
    XCTAssertThrowsError(try codeThatThrows(), message) { someError in
            guard let expectedErrorType = someError as? ExpectedError else {
                XCTFail("Expected code to throw error of type: <\(ExpectedError.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
                return
            }
            XCTAssertEqual(expectedErrorType, error)
        }
}

func XCTAssertThrowsSpecificError<ExpectedError>(
    _ codeThatThrows: @autoclosure () throws -> Void,
    _ error: ExpectedError,
    _ message: String = ""
) where ExpectedError: Swift.Error & Equatable {
        XCTAssertThrowsError(try codeThatThrows(), message) { someError in
            guard let expectedErrorType = someError as? ExpectedError else {
                XCTFail("Expected code to throw error of type: <\(ExpectedError.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
                return
            }
            XCTAssertEqual(expectedErrorType, error)
        }
}

func XCTAssertThrowsSpecificErrorType<Error>(
    _ codeThatThrows: @autoclosure () throws -> Void,
    _ errorType: Error.Type,
    _ message: String = ""
) where Error: Swift.Error & Equatable {
    XCTAssertThrowsError(try codeThatThrows(), message) { someError in
        XCTAssertTrue(someError is Error, "Expected code to throw error of type: <\(Error.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
    }
}

func XCTAssertContains(_ haystack: String?, _ needle: String?) {
    guard let needle = needle else { return XCTFail("Needle is nil") }
    guard let haystack = haystack else { return XCTFail("Haystack is nil") }
    XCTAssertTrue(haystack.contains(needle))
}

func XCTAssertNotContains(_ haystack: String?, _ needle: String?) {
    guard let haystack = haystack else { return XCTFail("Haystack is nil") }
    guard let needle = needle else {
        return // Definition... we expected haystack to NOT contain needle, if needle is nil, did we actually pass the test?
    }
    XCTAssertFalse(haystack.contains(needle))
}


func XCTAssertAllEqual<Item>(_ items: Item...) where Item: Equatable {
    forAll(items) {
        XCTAssertEqual($0, $1)
    }
}

func XCTAssertAllInequal<Item>(_ items: Item...) where Item: Equatable {
    forAll(items) {
        XCTAssertNotEqual($0, $1)
    }
}

private func forAll<Item>(_ items: [Item], compareElemenets: (Item, Item) -> Void) where Item: Equatable {
    var lastIndex: Array<Item>.Index?
    for index in items.indices {
        defer { lastIndex = index }
        guard let last = lastIndex else { continue }
        let fooElement: Item = items[last]
        let barElement: Item = items[index]
        compareElemenets(fooElement, barElement)
    }
}
