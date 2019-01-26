//
//  Base58Tests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class Base58Tests: XCTestCase {

    func testBase58ToHexString() {
        let data = Base58String(validated: "JHd1zCEKkXMhwz7GgSuENRrcFpPKveWugkFCn4u1NCqfc629zH6").asData
        XCTAssertEqual("0203c944bd6aa376389cf56d0bc5ed2a157a581caeb632d0cd2d26b6fb168ff70d065cd0c6d9", data.hex)
        XCTAssertEqual(
            "5cd0c6d96f397d62a3ac17687d05656ae11bc8ddfdaea5594f9cf5cf0926a3fb",
            RadixHash(unhashedData: data.prefix(data.count - 4), hashedBy: Sha256TwiceHasher()).toHexString()
        )
    }

}
