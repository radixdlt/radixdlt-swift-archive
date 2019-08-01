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

extension DefaultHTTPClient {
    static var localhost: DefaultHTTPClient {
        return DefaultHTTPClient(baseURL: URLFormatter.localhost)
    }
}

extension DefaultRESTClient {
    static var localhost: DefaultRESTClient {
        return DefaultRESTClient(formattedUrl: FormattedURL.localhost)
    }
}

class URLFormatterTests: XCTestCase {

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

    func testHttpClientFromLocalhost() {
        let client: DefaultHTTPClient = .localhost
        XCTAssertEqual(client.baseUrl.absoluteString, "http://localhost:8080/api")
    }

    func testRestClientFromLocalhost() {
        let client: DefaultRESTClient = .localhost
        XCTAssertEqual((client.httpClient as! DefaultHTTPClient).baseUrl.absoluteString, "http://localhost:8080/api")
    }

    func testLocalhost() {
        let host: String = .localhost
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
        let host = "127.0.0.1"
        do {
            let formattedUrl = try URLFormatter.format(host: Host(domain: host, port: 65000), protocol: .websockets)
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
            let formattedUrl = try URLFormatter.format(host: Host(domain: host, port: 1), protocol: .websockets, useSSL: false)
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
