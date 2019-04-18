//
//  GetUniverseOverWS.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking

class GetUniverseOverWebSocketsTest: WebsocketTest {
    
    func testGetUniverse() {
        guard let rpcClient = makeRpcClient() else { return }
        guard let universeConfig = rpcClient.getUniverseConfig().blockingTakeFirst() else { return }
        
        XCTAssertEqual(universeConfig.description, "The Radix development Universe")
        XCTAssertEqual(universeConfig.magic, 63799298)
    }
    
    // This is kind of a test of my mock
    func testGetUniverseConfigMockedGoodJson() {
        let subject = ReplaySubject<String>.create(bufferSize: 1)
        let mockedWebsocket = MockedWebsocket(subject: subject)
        let mockedRpcClient = MockedRPCClient(channel: mockedWebsocket)
        subject.onNext(goodJsonUniverseConfig)
        let universeConfig = try! mockedRpcClient.getUniverseConfig().take(1).toBlocking(timeout: 2).first()!
        
        XCTAssertEqual(universeConfig.description, "The Radix development Universe")
        XCTAssertEqual(universeConfig.magic, 63799298)
    }
    
    func testGetUniverseConfigMockedBadJson() {
        let subject = ReplaySubject<String>.create(bufferSize: 1)
        let mockedWebsocket = MockedWebsocket(subject: subject)
        let mockedRpcClient = MockedRPCClient(channel: mockedWebsocket)
        subject.onNext(badJsonUniverseConfig)
        XCTAssertThrowsError(try mockedRpcClient.getUniverseConfig().take(1).toBlocking(timeout: 1).first(), "Should throw error when receiving error from API") { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}

private let badJsonUniverseConfig = """
{
	"id": 0,
	"jsonrpc": "2.0",
	"result": {
		"description": ":str:The Radix development Universe"
	}
}
"""

private let goodJsonUniverseConfig = """
{
	"id": 0,
	"jsonrpc": "2.0",
	"result": {
		"creator": ":byt:A3hanCWf3pmR5E+i+wtWWfKleBrDOQduLb/vcFKOSt9o",
		"description": ":str:The Radix development Universe",
		"genesis": [
			{
				"hid": ":uid:3da6eac3ec0c2cab306aa629ab8112ff",
				"metaData": {
					"timestamp": ":str:1488326400000"
				},
				"particleGroups": [
					{
						"hid": ":uid:88333b74e70968d8361695c007cea90d",
						"particles": [
							{
								"hid": ":uid:eb9c8261b3d8900fa3774406b5881d1e",
								"particle": {
									"bytes": ":byt:UmFkaXguLi4ganVzdCBpbWFnaW5lIQ==",
									"from": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
									"hid": ":uid:f369e27c5796edb8b256102369427e64",
									"serializer": "\(RadixModelType.messageParticle.serializerId)",
									"to": ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
									"version": 100
								},
								"serializer": "\(RadixModelType.spunParticle.serializerId)",
								"spin": 1,
								"version": 100
							}
						],
						"serializer": "\(RadixModelType.particleGroup.serializerId)",
						"version": 100
					},
				],
				"serializer": "\(RadixModelType.atom.serializerId)",
				"shards": [
					6245273567170682628
				],
				"signatures": {
					"56abab3870585f04d015d55adf600bc7": {
						"hid": ":uid:649ed100c51e281718a6fb63b279ab99",
						"r": ":byt:MXBivsvqy2a+g2LYD8M0TfuUPM7PYoOlLNQvOpOwSXU=",
						"s": ":byt:4gaMu5HkTA/79V91SYXkEul6esGUGTtXh09GGxblOMA=",
						"serializer": "\(RadixModelType.signature.serializerId)",
						"version": 100
					}
				}
			}
		],
		"hid": ":uid:25a33c97af08b16b551acc331c3caf3c",
		"magic": 63799298,
		"name": ":str:Radix Devnet",
		"planck": 60000,
		"port": 30000,
		"serializer": "radix.universe",
		"timestamp": 1488326400000,
		"type": 2,
		"version": 100
	}
}
"""
