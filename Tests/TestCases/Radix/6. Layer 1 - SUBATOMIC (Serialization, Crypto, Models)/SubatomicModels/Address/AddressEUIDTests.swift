//
//  AddressEUIDTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import XCTest

class AddressEUIDTests: XCTestCase {
    
    func testHashIdOfAddress() {
        // GIVEN
        // An address
        let address: Address = "JHB89drvftPj6zVCNjnaijURk8D8AMFw4mVja19aoBGmRXWchnJ"
        
        // WHEN
        // I calculate it's hashEUID ("hid")
        let hashEUID = address.hashEUID
        
        // THEN
        // It equals the one produces by the Java lib
        XCTAssertEqual(
            hashEUID,
            "8cfef50ea6a767813631490f9a94f73f",
            "Should equal the value from Java library"
        )
    }
}
