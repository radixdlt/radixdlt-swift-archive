//
//  TestThatSignaturesOfAtomAreExcludedInDsonHash.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class TestSigDson: XCTestCase {
    func testThatSignaturesAreOmittedFromDsonHash() {
        let atom = try! JSONDecoder().decode(Atom.self, from: json.toData())
        XCTAssertEqual(atom.hashId.hex, "4de0f8a2f14a1dfda9eec97314558ff4")
    }
}

class TestOptionSetRemoving: XCTestCase {
    func testRemoving() {
        var outputAll = DSONOutput.all
        XCTAssertTrue(outputAll.contains(.wire))
        XCTAssertTrue(outputAll.contains(.persist))
        XCTAssertTrue(outputAll.contains(.api))
        XCTAssertTrue(outputAll.contains(.hash))
        outputAll.remove(.hash)
        XCTAssertFalse(outputAll.contains(.hash))
    }
    
    func testAllRemoveHash() {
        let allRemoveHash = DSONOutput.all.removing(.hash)
        XCTAssertTrue(allRemoveHash.contains(.wire))
        XCTAssertTrue(allRemoveHash.contains(.persist))
        XCTAssertTrue(allRemoveHash.contains(.api))
        XCTAssertFalse(allRemoveHash.contains(.hash))
    }
    
    func testAllButHash() {
        let allButHash = DSONOutput.allButHash
        XCTAssertTrue(allButHash.contains(.wire))
        XCTAssertTrue(allButHash.contains(.persist))
        XCTAssertTrue(allButHash.contains(.api))
        XCTAssertFalse(allButHash.contains(.hash))
    }
    
    func testRawValues() {
        XCTAssertEqual(DSONOutput.all.rawValue, 15)
        XCTAssertEqual(DSONOutput.allButHash.rawValue, 14)
        XCTAssertEqual(DSONOutput.hash.rawValue, 1)
    }
    
}

private let json = """
{
	"metaData": {
		"timestamp": ":str:1488326400000"
	},
	"shards": [
		6245273567170682628
	],
	"hid": ":uid:3da6eac3ec0c2cab306aa629ab8112ff",
	"serializer": "\(RadixModelType.atom.serializerId)",
	"version": 100,
	"particleGroups": [
		{
			"hid": ":uid:88333b74e70968d8361695c007cea90d",
			"serializer": "\(RadixModelType.particleGroup.serializerId)",
			"particles": [
				{
					"hid": ":uid:eb9c8261b3d8900fa3774406b5881d1e",
					"spin": 1,
					"serializer": "\(RadixModelType.spunParticle.serializerId)",
					"particle": {
						"hid": ":uid:f369e27c5796edb8b256102369427e64",
						"bytes": ":byt:UmFkaXguLi4ganVzdCBpbWFnaW5lIQ==",
						"serializer": "\(RadixModelType.messageParticle.serializerId)",
						"from": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
						"to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
						"version": 100
					},
					"version": 100
				}
			],
			"version": 100
		},
		{
			"hid": ":uid:a617a30a04480209ca6df28d099de08d",
			"serializer": "\(RadixModelType.particleGroup.serializerId)",
			"particles": [
				{
					"hid": ":uid:2652642a012a6a003fb7e40f6550ff83",
					"spin": 1,
					"serializer": "\(RadixModelType.spunParticle.serializerId)",
					"particle": {
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
						"serializer": "\(RadixModelType.tokenDefinitionParticle.serializerId)",
						"description": ":str:Radix Native Tokens",
						"version": 100
					},
					"version": 100
				},
				{
					"hid": ":uid:7b90ac8a04ad09bc3ad8553f206ad181",
					"spin": 1,
					"serializer": "\(RadixModelType.spunParticle.serializerId)",
					"particle": {
						"amount": ":u20:115792089237316195423570985008687907853269984665640564039457584007913129639935",
						"hid": ":uid:a9aeebdc0f95784abba3fed8be608288",
						"granularity": ":u20:1",
						"permissions": {
							"mint": ":str:token_creation_only",
							"burn": ":str:none"
						},
						"serializer": "\(RadixModelType.unallocatedTokensParticle.serializerId)",
						"version": 100,
						"nonce": 352745977011091,
						"tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
					},
					"version": 100
				}
			],
			"version": 100
		},
		{
			"hid": ":uid:1a2303125c7b8f7acd4b87a729dce024",
			"serializer": "\(RadixModelType.particleGroup.serializerId)",
			"particles": [
				{
					"hid": ":uid:6bd82db0a52e58efdbe3e09d956d0482",
					"spin": -1,
					"serializer": "\(RadixModelType.spunParticle.serializerId)",
					"particle": {
						"amount": ":u20:115792089237316195423570985008687907853269984665640564039457584007913129639935",
						"hid": ":uid:a9aeebdc0f95784abba3fed8be608288",
						"granularity": ":u20:1",
						"permissions": {
							"mint": ":str:token_creation_only",
							"burn": ":str:none"
						},
						"serializer": "\(RadixModelType.unallocatedTokensParticle.serializerId)",
						"version": 100,
						"nonce": 352745977011091,
								"tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
							},
							"version": 100
						},
						{
							"hid": ":uid:0251143bb7f370e598c2e5a67b6fae81",
							"spin": 1,
							"serializer": "\(RadixModelType.spunParticle.serializerId)",
							"particle": {
								"amount": ":u20:115792089237316195423570985008687907853269984665639564039457584007913129639935",
								"hid": ":uid:1d9754c1a361fdd49464fc7eee56069f",
								"granularity": ":u20:1",
								"permissions": {
									"mint": ":str:token_creation_only",
									"burn": ":str:none"
								},
								"serializer": "\(RadixModelType.unallocatedTokensParticle.serializerId)",
								"version": 100,
								"nonce": 352745977021922,
								"tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD"
							},
							"version": 100
						},
						{
							"hid": ":uid:ae2a27e67c5b77e09bf3b30218dcef87",
							"spin": 1,
							"serializer": "\(RadixModelType.spunParticle.serializerId)",
							"particle": {
								"amount": ":u20:1000000000000000000000000000",
								"hid": ":uid:23151a1bd487f8f9a61cf12998e0119c",
								"address": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
								"granularity": ":u20:1",
								"permissions": {
									"mint": ":str:token_creation_only",
									"burn": ":str:none"
								},
								"serializer": "\(RadixModelType.transferrableTokensParticle.serializerId)",
								"version": 100,
								"nonce": 352745977020188,
								"tokenDefinitionReference": ":rri:/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/tokens/XRD",
								"planck": 24805440
							},
							"version": 100
						}
					],
					"version": 100
				}
			],
			"signatures": {
				"56abab3870585f04d015d55adf600bc7": {
					"r": ":byt:MXBivsvqy2a+g2LYD8M0TfuUPM7PYoOlLNQvOpOwSXU=",
					"hid": ":uid:649ed100c51e281718a6fb63b279ab99",
					"s": ":byt:4gaMu5HkTA/79V91SYXkEul6esGUGTtXh09GGxblOMA=",
					"serializer": "\(RadixModelType.signature.serializerId)",
					"version": 100
				}
			},
		}
"""
