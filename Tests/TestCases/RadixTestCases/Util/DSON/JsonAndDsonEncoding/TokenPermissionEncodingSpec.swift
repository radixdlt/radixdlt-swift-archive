//
//  TokenPermissionEncoding.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import Quick
import Nimble

class TokenPermissionEncodingSpec: QuickSpec {
    override func spec() {
        describe("Encoding of TokenPermission") {
            let permissions = TokenPermissions.all
            describe("to JSON") {
                let jsonString = String(
                    data: try! JSONEncoder().encode(permissions),
                    encoding: .utf8
                )!
                it("its values are prefixed with :str:") {
                    expect(jsonString).to(contain(":str:all"))
                }
            }
            describe("to Dson") {
                let dsonHex = try! permissions.toDSON().hex
                it("its values are not prefixed with :str:") {
                    expect(dsonHex).to(contain(
                        ["burn", "all"].map { try! $0.toDSON().hex }.joined()
                    ))
                    expect(dsonHex).toNot(contain(try! ":str:all".toDSON().hex))
                }
            }
        }
    }
}
