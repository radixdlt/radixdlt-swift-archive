//
//  URLFormatterTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
        return DefaultRESTClient(url: URLFormatter.localhost)
    }
}

class URLFormatterTests: XCTestCase {

    func testCorrectHttpsUrl() {
        let host = "0.0.0.0"
        do {
            let formattedUrl = try URLFormatter.format(ipAddress: host, port: 123, protocol: .hypertext(appendPath: true))
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
            let formattedUrl = try URLFormatter.format(ipAddress: host, port: 123, protocol: .hypertext(appendPath: true), useSSL: false)
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
            let formattedUrl = try URLFormatter.format(ipAddress: host, port: 237, protocol: .hypertext(appendPath: true), useSSL: false)
            let url = formattedUrl.url
            XCTAssertEqual(url.host, host)
            XCTAssertEqual(url.port, 237)
            XCTAssertEqual(url.scheme, "http")
            XCTAssertEqual(url.path, "/api")
        } catch {
            XCTFail("Failed to create url, error: \(error)")
        }
    }
    
    func testCorrectWssUrl() {
        let host = "127.0.0.1"
        do {
            let formattedUrl = try URLFormatter.format(ipAddress: host, port: 65000, protocol: .websockets(appendPath: true))
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
            let formattedUrl = try URLFormatter.format(ipAddress: host, port: 1, protocol: .websockets(appendPath: true), useSSL: false)
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
