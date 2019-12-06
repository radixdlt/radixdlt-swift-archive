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

final class HostTests: TestCase {

    func testDifferentDomainAndDifferentPortNotEquals() {
        XCTAssertNotEqual(
            try Host(domain: "8.8.8.3", port: 1),
            try Host(domain: "8.8.8.4", port: 2)
        )
    }

    func testDifferentDomainAndSamePortNotEquals() {
        XCTAssertNotEqual(
            try Host(domain: "8.8.8.3", port: 1),
            try Host(domain: "8.8.8.4", port: 1)
        )
    }
    
    func testSameDomainAndDifferentPortNotEquals() {
        XCTAssertNotEqual(
            try Host(domain: "8.8.8.8", port: 1),
            try Host(domain: "8.8.8.8", port: 2)
        )
    }
    
    func testSameDomainAndSamePortEquals() {
        XCTAssertEqual(
            try Host(domain: "8.8.8.8", port: 1),
            try Host(domain: "8.8.8.8", port: 1)
        )
    }
    
    func testOfExpressibleByStringInterpolation() {
        XCTAssertEqual(
            try Host(domain: "8.8.8.8", port: 1),
            "8.8.8.8:1"
        )
    }
    
    func testLocalhostWithAlphanumerics() throws {
        let host = try Host(domain: "localhost", port: 237)
        XCTAssertEqual(host.urlString, "localhost:237")
    }
    
    func testLocalhostWith127xxx() throws {
        let host = try Host(domain: "127.6.5.4", port: 237)
        XCTAssertEqual(host.urlString, "127.6.5.4:237")
    }
    
    func testLocalhostStaticFuncUsingDefaultPort() {
        let host = Host.local()
        XCTAssertEqual(host.urlString, "localhost:8080")
    }
    
    func testCompareLocalhostLettersAndNumbersResultInError() {
        let foo: Host = "\(String.localhostLetters):8080"
        let bar: Host = "\(String.localhostNumbers):8080"
        XCTAssertThrowsSpecificError(
            try Host.compareDomains(of: foo, and: bar),
            Host.Error.bothDomainsAreLocalhostButOneUsesLettersAndOtherNumbers
        )
    }
    
    func testAssertEqualLocalhostLetters() {
        XCTAssertEqual(
            try Host(domain: .localhostLetters, port: 1),
            try Host(domain: .localhostLetters, port: 1)
        )
    }
    
    func testAssertEqualLocalhostNumbers() {
        XCTAssertEqual(
            try Host(domain: .localhostNumbers, port: 1),
            try Host(domain: .localhostNumbers, port: 1)
        )
    }
}

extension Host: ExpressibleByStringInterpolation {
    public init(stringLiteral string: String) {
        do {
            let domainAndPort = string.components(separatedBy: ":")
            guard
                domainAndPort.count == 2,
                let domainString = domainAndPort.first,
                let portString = domainAndPort.last,
                let portInt = UInt16(portString)
                else {
                    fatalError("Bad literal: \(string)")
            }
            
            try self.init(domain: domainString, port: Port(portInt))
        } catch {
            badLiteralValue(string, error: error)
        }
    }
}
