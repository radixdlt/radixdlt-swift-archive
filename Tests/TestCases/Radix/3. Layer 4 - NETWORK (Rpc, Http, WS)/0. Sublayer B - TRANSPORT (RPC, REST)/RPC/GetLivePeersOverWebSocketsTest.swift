//
//  WebSocketsGetLivePeersTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest


class GetLivePeersOverWebSocketsTest: WebsocketTest {
    
    func testLivePeersOverWS() {
        guard let rpcClient = makeRpcClient() else { return }
        guard let livePeers = rpcClient.getLivePeers().blockingTakeFirst(timeout: 1) else { return }
        
        XCTAssertEqual(livePeers.count, 1)
        let livePeer = livePeers[0]
        XCTAssertFalse(livePeer.host.ipAddress.isEmpty)
    }
    
    // This is kind of a test of my mock
    func testLivePeersMockedGoodJson() {
        let subject = ReplaySubject<String>.create(bufferSize: 1)
        let mockedWebsocket = MockedWebsocket(subject: subject)
        let mockedRpcClient = MockedRPCClient(channel: mockedWebsocket)
        subject.onNext(goodJsonLivePeers)
        
        guard let livePeers = mockedRpcClient.getLivePeers().blockingTakeFirst(timeout: 1) else { return }
        
        XCTAssertEqual(livePeers.count, 1)
        let livePeer = livePeers[0]
        XCTAssertFalse(livePeer.host.ipAddress.isEmpty)
    }
    
    func testLivePeersMockedBadJson() {
        let subject = ReplaySubject<String>.create(bufferSize: 1)
        let mockedWebsocket = MockedWebsocket(subject: subject)
        let mockedRpcClient = MockedRPCClient(channel: mockedWebsocket)
        subject.onNext(badJsonLivePeers)

        XCTAssertThrowsSpecificError(
            try mockedRpcClient.getLivePeers().take(1).toBlocking(timeout: 1).first(),
            RPCError.failedToDecodeResponse(DecodingError.keyNotFound(NodeInfo.CodingKeys.system)),
            "Should throw error when receiving error from API"
        )
    }
    
}

struct MockedWebsocket: FullDuplexCommunicationChannel {
    func sendMessage(_ message: String) {
        /* doing nothing */
    }

    var messages: Observable<String>
    init(messages: Observable<String>) {
        self.messages = messages
    }
    
    init(subject: ReplaySubject<String>) {
        self.init(messages: subject.asObservable())
    }
}

struct MockedRPCClient: RPCClient, FullDuplexCommunicating {
    let channel: FullDuplexCommunicationChannel
    init(channel: FullDuplexCommunicationChannel) {
        self.channel = channel
    }
    
    func getLivePeers() -> SingleWanted<[NodeInfo]> {
        return channel.responseForMessage(with: nil)
    }
    
    func getUniverseConfig() -> SingleWanted<UniverseConfig> {
        return channel.responseForMessage(with: nil)
    }
}

private let goodJsonLivePeers = """
{
	"id": 0,
	"jsonrpc": "2.0",
	"result": [
        {
			"hid": ":uid:121b8bb9550da9f469a01e2220416dd3",
			"host": {
				"ip": ":str:172.18.0.3",
				"port": 30000
			},
			"protocols": [
				":str:UDP"
			],
			"serializer": "network.peer",
			"system": {
				"agent": {
					"name": ":str:/Radix:/2700000",
					"protocol": 100,
					"version": 2700000
				},
				"clock": 1,
				"commitment": ":hsh:0100000000000000000000000000000000000000000000000000000000000000",
				"hid": ":uid:a3c0d67bc4e62bb51d5dba2c83bb41d3",
				"key": ":byt:A1gV7wL3K35gW1AEo9NRi9Me9K1erHT80udvu5L88Tz2",
				"nid": ":uid:ed159db66f945b9722c6579ab185aa60",
				"planck": 24805440,
				"port": 30000,
				"serializer": "api.system",
				"shards": {
					"anchor": -1363009905328104553,
					"range": {
						"high": 8796093022207,
						"low": -8796093022208,
						"serializer": "radix.shards.range"
					},
					"serializer": "radix.shard.space"
				},
				"timestamp": 1488326400000,
				"version": 100
			},
			"version": 100
		}
	]
}
"""

private let badJsonLivePeers = """
{
	"id": 0,
	"jsonrpc": "2.0",
	"result": [
		{
			"host": {
				"ip": ":str:172.18.0.3",
				"port": 30000
			}
		}
	]
}
"""
