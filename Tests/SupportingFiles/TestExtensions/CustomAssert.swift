//
//  CustomAssert.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
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

func XCTAssertThrowsSpecificErrorType<E>(
    _ codeThatThrows: @autoclosure () throws -> Void,
    _ errorType: E.Type,
    _ message: String = ""
) where E: Swift.Error & Equatable {
    XCTAssertThrowsError(try codeThatThrows(), message) { someError in
        XCTAssertTrue(someError is E, "Expected code to throw error of type: <\(E.self)>, but got error: <\(someError)>, of type: <\(type(of: someError))>")
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
