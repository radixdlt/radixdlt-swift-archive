//
//  TokenPermissionEncoding.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class TokenPermissionEncodingTests: XCTestCase {

    
    func testJsonEncodedIsPrefixed() {
        // GIVEN
        // TokenPermissions
        let permissions = TokenPermissions.all
        
        // WHEN
        // JSON encoding
        guard let jsonString = jsonStringOrFail(permissions) else { return }
        
        // THEN
        // The string is prefixed with ":str:"
        XCTAssertContains(jsonString, ":str:all")
    }
    
    func testDsonEncodedIsNotPrefixed() {
        // GIVEN
        // TokenPermissions
        let permissions = TokenPermissions.all
        
        // WHEN
        // DSON encoding
        guard let dsonHex = dsonHexStringOrFail(permissions, output: .all) else { return }
        
        // THEN
        // The string is not prefixed with ":str:"
        XCTAssertNotContains(dsonHex, ":str:all")
        // ... but contains DSON hex for "burn" and "all"
        XCTAssertContains(
            dsonHex,
             ["burn", "all"].compactMap { dsonHexStringOrFail($0, output: .all) }.joined()
        )
    }
}

