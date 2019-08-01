//
//  NodeDiscoveryTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift

class NodeDiscoveryTests: LocalhostNodeTest {

    func testLocalHost() {
        let nodeDiscovery: NodeDiscoveryHardCoded = .localhost
        guard let nodeArray = nodeDiscovery.loadNodes().blockingTakeFirst() else { return }
        XCTAssertEqual(nodeArray.count, 1)
        let node = nodeArray[0]
        XCTAssertEqual(node.httpUrl.url.absoluteString, "http://localhost:8080/api")
        XCTAssertEqual(node.websocketsUrl.url.absoluteString, "ws://localhost:8080/rpc")
    }
    
    func testNodeFinder() {
        let nodeFinder = OriginNodeFinder.betanet
        let originNode = nodeFinder.findSomeOriginNode().blockingTakeFirst()
        XCTAssertNotNil(originNode)
    }
    
    // This is kind of a test of my mock
//    func testLoadNodesMockedGoodJson() {
//        let mockedResponses = ReplaySubject<String>.create(bufferSize: 1)
//        let mockedFindNode = MockedFindNodeRequester(observable: mockedResponses.asObserver().map { _ in FormattedURL.empty  })
//        let mockedRestClient = DefaultRESTClient(httpClient: MockedHTTPClient(httpResponse: mockedResponses.asObservable()))
//
//        let nodeFinder = NodeFinder(
//            nodeFindingURL: FormattedURL.empty,
//            makeFindNodeRequester: { _ in mockedFindNode },
//            makeLivePeersRequester: { _ in mockedRestClient }
//        )
//        mockedResponses.onNext(goodJsonNodes)
//        guard let nodes = nodeFinder.loadNodes().blockingTakeFirst() else { return }
//        XCTAssertFalse(nodes.isEmpty)
//    }
//
//    func testLoadNodesMockedBadJson() {
//        let mockedResponses = ReplaySubject<String>.create(bufferSize: 2)
//        let mockedFindNode = MockedFindNodeRequester(observable: mockedResponses.asObserver().map { _ in FormattedURL.empty  })
//        let mockedRestClient = DefaultRESTClient(httpClient: MockedHTTPClient(httpResponse: mockedResponses.asObservable()))
//
//        let nodeFinder = NodeFinder(
//            nodeFindingURL: FormattedURL.empty,
//            makeFindNodeRequester: { _ in mockedFindNode },
//            makeLivePeersRequester: { _ in mockedRestClient }
//        )
//        mockedResponses.onNext("35.111.222.212")
//        mockedResponses.onNext(badJsonNodes)
//
//        XCTAssertThrowsSpecificError(
//            try nodeFinder.loadNodes().take(1).toBlocking(timeout: 1).first(),
//            DecodingError.invalidJSON
//        )
//    }
    
//    func testIncorrectIP() {
//        // Some incorrect IP address
//        let nodeDiscovery = try! NodeDiscoveryHardCoded(hosts: ["35.111.222.212"])
//        XCTAssertThrowsError(try nodeDiscovery.loadNodes().take(1).toBlocking(timeout: 1).first())
//    }
//
//    func testNodeFinderBadURL() {
//        let nodeFinder = try! NodeFinder(bootstrapHost: try! Host(domain: "google.com", port: 443))
//        XCTAssertThrowsError(try nodeFinder.loadNodes().take(1).toBlocking(timeout: 1).first())
//    }
}

extension FormattedURL {
    static var empty: FormattedURL {
        return FormattedURL(
            url: URL(stringLiteral: "http://\(String.localhost)"),
            domain: .localhost,
            port: 8080,
            isUsingSSL: false
        )
    }
}

//struct MockedFindNodeRequester: OriginNodeFinding {
//    private let observable: Observable<FormattedURL>
//    init(observable: Observable<FormattedURL>) {
//        self.observable = observable
//    }
//    func findNode() -> Single<FormattedURL> {
//        return observable
//    }
//}

//private let badJsonNodes = """
//[
//    {
//        "host": {
//            "ip": ":str:35.204.138.88",
//            "port": 30000
//        },
//        "serializer": "network.peer",
//        "version": 100
//    }
//]
//"""
//
//private let goodJsonNodes = """
//[
//    {
//        "hid": ":uid:121b8bb9550da9f469a01e2220416dd3",
//        "host": {
//            "ip": ":str:172.18.0.3",
//            "port": 30000
//        },
//        "protocols": [
//            ":str:UDP"
//        ],
//        "serializer": "network.peer",
//        "system": {
//            "agent": {
//                "name": ":str:/Radix:/2700000",
//                "protocol": 100,
//                "version": 2700000
//            },
//            "clock": 1,
//            "commitment": ":hsh:0100000000000000000000000000000000000000000000000000000000000000",
//            "hid": ":uid:a3c0d67bc4e62bb51d5dba2c83bb41d3",
//            "key": ":byt:A1gV7wL3K35gW1AEo9NRi9Me9K1erHT80udvu5L88Tz2",
//            "nid": ":uid:ed159db66f945b9722c6579ab185aa60",
//            "planck": 24805440,
//            "port": 30000,
//            "serializer": "api.system",
//            "shards": {
//                "anchor": -1363009905328104553,
//                "range": {
//                    "high": 8796093022207,
//                    "low": -8796093022208,
//                    "serializer": "radix.shards.range"
//                },
//                "serializer": "radix.shard.space"
//            },
//            "timestamp": 1488326400000,
//            "version": 100
//        },
//        "version": 100
//    }
//]
//
//"""
