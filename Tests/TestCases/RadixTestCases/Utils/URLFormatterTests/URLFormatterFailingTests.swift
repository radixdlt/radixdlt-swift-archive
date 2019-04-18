//
//  URLFormatterFailingTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Quick
import Nimble

class URLFormatterIncorrectUrlsSpec: QuickSpec {
    override func spec() {
        describe("Failing URL formatting") {
            it("should fail when IP address contains > UInt8.max") {
                expect { try URLFormatter.format(url: Host(ipAddress: "256.0.0.0", port: 1), protocol: .hypertext, useSSL: false) }.to(throwError(URLFormatter.Error.nonHostStringPassed(url: "")))
            }
            
            it("should fail when IP address contains path") {
                expect { try URLFormatter.format(url: Host(ipAddress: "0.0.0.0/foobar", port: 1), protocol: .hypertext, useSSL: false) }.to(throwError(URLFormatter.Error.nonHostStringPassed(url: "")))
            }

            it("should fail when using localhost trying SSL") {
                expect { try URLFormatter.format(url: Host(ipAddress: "localhost", port: 123), protocol: .hypertext, useSSL: true) }.to(throwError(URLFormatter.Error.sslIsUnsupportedForLocalhost))
            }
        }
    }
}
