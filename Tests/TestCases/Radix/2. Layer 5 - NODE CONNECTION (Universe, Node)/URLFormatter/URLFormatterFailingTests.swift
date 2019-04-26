//
//  URLFormatterFailingTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class URLFormatterIncorrectUrlsTests: XCTestCase {

    func testUInt8OverflowInIpAddress() {
        // GIVEN
        // An address containing `256`, which does not fit in UInt8
        let ipAddress = "256.0.0.0"
        
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try to create a FormattedURL from it
            try URLFormatter.format(url: Host(ipAddress: ipAddress, port: 1), protocol: .hypertext, useSSL: false),
            // THEN
            URLFormatter.Error.nonHostStringPassed(url: ipAddress),
            "It should fail when IP address contains > UInt8.max"
        )
    }

    func testAddressContainingPath() {
        // GIVEN
        // An address containing a path `/foobar` which is not allowed
        let ipAddress = "0.0.0.0/foobar"
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try to create a FormattedURL from it
            try URLFormatter.format(url: Host(ipAddress: ipAddress, port: 1), protocol: .hypertext, useSSL: false),
             // THEN
            URLFormatter.Error.nonHostStringPassed(url: ipAddress),
            "It should fail when IP address contains path"
        )
    }

    func testFailingURLFormatting3() {
        // GIVEN
        // A "localhost" address
        XCTAssertThrowsSpecificError(
            // WHEN
            // I try to format URL using SSL
            try URLFormatter.format(url: Host(ipAddress: "localhost", port: 123), protocol: .hypertext, useSSL: true),
            // THEN
            URLFormatter.Error.sslIsUnsupportedForLocalhost,
            "It should throw an error saying SSL is unsupported for localhost"
        )
    }
}
