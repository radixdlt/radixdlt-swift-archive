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
            try URLFormatter.format(host: Host(domain: ipAddress, port: 1), protocol: .hypertext, useSSL: false),
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
            try URLFormatter.format(host: Host(domain: ipAddress, port: 1), protocol: .hypertext, useSSL: false),
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
            try URLFormatter.format(host: Host(domain: "localhost", port: 123), protocol: .hypertext, useSSL: true),
            // THEN
            URLFormatter.Error.sslIsUnsupportedForLocalhost,
            "It should throw an error saying SSL is unsupported for localhost"
        )
    }
}
