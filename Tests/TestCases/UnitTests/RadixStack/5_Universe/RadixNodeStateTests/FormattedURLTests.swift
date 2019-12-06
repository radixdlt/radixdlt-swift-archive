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

import XCTest
@testable import RadixSDK


class FormattedURLTests: TestCase {
    
    func testFormatterOutputsFormattedURL() throws {
        let result = try URLFormatter.format(host: "8.8.8.8:1", protocol: .hypertext)
        XCTAssertType(of: result, is: FormattedURL.self)
    }

    func testEquals() {
        let host: Host = "8.8.8.8:1"
        XCTAssertEqual(
            try URLFormatter.format(host: host, protocol: .hypertext, useSSL: true),
            try URLFormatter.format(host: host, protocol: .hypertext, useSSL: true)
        )
    }
    
    func testDefaultValueOfSSLIsTrue() throws {
        let formattedURL = try URLFormatter.format(host: "8.8.8.8:1", protocol: .hypertext)
        XCTAssertTrue(formattedURL.url.absoluteString.starts(with: "https"))
    }
    
    func testLocalhostLettersWithSSLThrowsError() {
        XCTAssertThrowsSpecificError(
            try URLFormatter.format(host: "localhost:8080", protocol: .hypertext, useSSL: true),
            URLFormatter.Error.sslIsUnsupportedForLocalhost
        )
    }
    
    func testLocalhostNumbersWithSSLThrowsError() {
        XCTAssertThrowsSpecificError(
            try URLFormatter.format(host: "127.0.0.1:8080", protocol: .hypertext, useSSL: true),
            URLFormatter.Error.sslIsUnsupportedForLocalhost
        )
    }
    
    func testAllSameButSSLFlag() {
        let host: Host = "8.8.8.8:1"
        XCTAssertNotEqual(
            try URLFormatter.format(host: host, protocol: .hypertext, useSSL: true),
            try URLFormatter.format(host: host, protocol: .hypertext, useSSL: false)
        )
    }
    
    func testAllSameButProtocol() {
        let host: Host = "8.8.8.8:1"
        XCTAssertNotEqual(
            try URLFormatter.format(host: host, protocol: .hypertext, useSSL: true),
            try URLFormatter.format(host: host, protocol: .hypertext, useSSL: false)
        )
    }
    
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
    
    func testCorrectHttpsUrl() {
        let host = "0.0.0.0"
        do {
            let formattedUrl = try URLFormatter.format(host: Host(domain: host, port: 123), protocol: .hypertext)
            let url = formattedUrl.url
            XCTAssertEqual(url.host, host)
            XCTAssertEqual(url.port, 123)
            XCTAssertEqual(url.scheme, "https")
            XCTAssertEqual(url.path, "/api")
        } catch {
            XCTFail("Failed to create url, error: \(error)")
        }
    }
    
    func testLocalhost() {
        let host: String = .localhostLetters
        do {
            let formattedUrl = try URLFormatter.format(host: Host(domain: host, port: 123), protocol: .hypertext, useSSL: false)
            let url = formattedUrl.url
            XCTAssertEqual(url.host, host)
            XCTAssertEqual(url.port, 123)
            XCTAssertEqual(url.scheme, "http")
            XCTAssertEqual(url.path, "/api")
        } catch {
            XCTFail("Failed to create url, error: \(error)")
        }
    }
    
    func testCorrectHttpUrl() {
        let host = "255.255.255.255"
        do {
            let formattedUrl = try URLFormatter.format(host: Host(domain: host, port: 123), protocol: .hypertext, useSSL: false)
            let url = formattedUrl.url
            XCTAssertEqual(url.host, host)
            XCTAssertEqual(url.port, 123)
            XCTAssertEqual(url.scheme, "http")
            XCTAssertEqual(url.path, "/api")
        } catch {
            XCTFail("Failed to create url, error: \(error)")
        }
    }
    
    func testCorrectWssUrl() {
        let host = "8.8.8.8"
        do {
            let formattedUrl = try URLFormatter.format(host: Host(domain: host, port: 65000), protocol: .webSockets)
            let url = formattedUrl.url
            XCTAssertEqual(url.host, host)
            XCTAssertEqual(url.port, 65000)
            XCTAssertEqual(url.scheme, "wss")
            XCTAssertEqual(url.path, "/rpc")
        } catch {
            XCTFail("Failed to create url, error: \(error)")
        }
    }
    
    func testCorrectWsUrl() {
        let host = "1.255.255.1"
        do {
            let formattedUrl = try URLFormatter.format(host: Host(domain: host, port: 1), protocol: .webSockets, useSSL: false)
            let url = formattedUrl.url
            XCTAssertEqual(url.host, host)
            XCTAssertEqual(url.port, 1)
            XCTAssertEqual(url.scheme, "ws")
            XCTAssertEqual(url.path, "/rpc")
        } catch {
            XCTFail("Failed to create url, error: \(error)")
        }
    }
}
