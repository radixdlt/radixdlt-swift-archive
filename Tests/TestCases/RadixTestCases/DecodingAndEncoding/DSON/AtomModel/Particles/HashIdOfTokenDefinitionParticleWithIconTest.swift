//
//  HashIdOfTokenDefinitionParticleWithIconTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class HashIdOfTokenDefinitionParticleWithIconTest: XCTestCase {
    func testHid() {
        let particle = try! JSONDecoder().decode(TokenDefinitionParticle.self, from: json.toData())
        XCTAssertEqual(particle.symbol, "XRD")
        XCTAssertEqual(particle.hashId.hex, "9fe87f7ec85d0510e769f13d5a23460d")
    }
}

private let json = """
{
  "symbol": ":str:XRD",
  "hid": ":uid:9fe87f7ec85d0510e769f13d5a23460d",
  "address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
  "granularity": ":u20:1",
  "permissions": {
    "mint": ":str:token_creation_only",
    "burn": ":str:none"
  },
  "name": ":str:Rads",
  "icon": ":byt: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",
  "serializer": -1135093134,
  "description": ":str:Radix Native Tokens",
  "version": 100
}
"""
