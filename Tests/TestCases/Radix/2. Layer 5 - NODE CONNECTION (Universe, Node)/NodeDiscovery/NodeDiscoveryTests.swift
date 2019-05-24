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

class NodeDiscoveryTests: XCTestCase {

    func testLocalHost() {
        let nodeDiscovery: NodeDiscoveryHardCoded = .localhost
        guard let nodeArray = nodeDiscovery.loadNodes().blockingTakeFirst() else { return }
        XCTAssertEqual(nodeArray.count, 1)
        let node = nodeArray[0]
        XCTAssertEqual(node.httpUrl.url.absoluteString, "http://localhost:8080/api")
        XCTAssertEqual(node.websocketsUrl.url.absoluteString, "ws://localhost:8080/rpc")
    }
    
//    func testNodeFinder() {
//        let nodeFinder: NodeFinder = .sunstone
//        guard let nodes = nodeFinder.loadNodes().blockingTakeFirst() else { return }
//        XCTAssertFalse(nodes.isEmpty)
//    }
    
    // This is kind of a test of my mock
    func testLoadNodesMockedGoodJson() {
        let mockedResponses = ReplaySubject<String>.create(bufferSize: 1)
        let mockedFindNode = MockedFindNodeRequester(observable: mockedResponses.asObserver().map { _ in FormattedURL.empty  })
        let mockedRestClient = DefaultRESTClient(httpClient: MockedHTTPClient(httpResponse: mockedResponses.asObservable()))
        
        let nodeFinder = NodeFinder(
            nodeFindingURL: FormattedURL.empty,
            makeFindNodeRequester: { _ in mockedFindNode },
            makeLivePeersRequester: { _ in mockedRestClient }
        )
        mockedResponses.onNext(goodJsonNodes)
        guard let nodes = nodeFinder.loadNodes().blockingTakeFirst() else { return }
        XCTAssertFalse(nodes.isEmpty)
    }
    
    func testLoadNodesMockedBadJson() {
        let mockedResponses = ReplaySubject<String>.create(bufferSize: 2)
        let mockedFindNode = MockedFindNodeRequester(observable: mockedResponses.asObserver().map { _ in FormattedURL.empty  })
        let mockedRestClient = DefaultRESTClient(httpClient: MockedHTTPClient(httpResponse: mockedResponses.asObservable()))
        
        let nodeFinder = NodeFinder(
            nodeFindingURL: FormattedURL.empty,
            makeFindNodeRequester: { _ in mockedFindNode },
            makeLivePeersRequester: { _ in mockedRestClient }
        )
        mockedResponses.onNext("35.111.222.212")
        mockedResponses.onNext(badJsonNodes)

        XCTAssertThrowsSpecificError(
            try nodeFinder.loadNodes().take(1).toBlocking(timeout: 1).first(),
            DecodingError.invalidJSON
        )
    }
    
    func testIncorrectIP() {
        // Some incorrect IP address
        let nodeDiscovery = try! NodeDiscoveryHardCoded(hosts: ["35.111.222.212"])
        XCTAssertThrowsError(try nodeDiscovery.loadNodes().take(1).toBlocking(timeout: 1).first())
    }

    func testNodeFinderBadURL() {
        let nodeFinder = try! NodeFinder(bootstrapHost: try! Host(ipAddress: "google.com", port: 443))
        XCTAssertThrowsError(try nodeFinder.loadNodes().take(1).toBlocking(timeout: 1).first())
    }
}

extension FormattedURL {
    static var empty: FormattedURL {
        return FormattedURL(
            url: URL(stringLiteral: "http://\(String.localhost)"),
            host: .localhost,
            port: 8080,
            isUsingSSL: false
        )
    }
}

struct MockedFindNodeRequester: NodeAddressRequesting {
    private let observable: Observable<FormattedURL>
    init(observable: Observable<FormattedURL>) {
        self.observable = observable
    }
    func findNode() -> SingleWanted<FormattedURL> {
        return observable
    }
}

private let badJsonNodes = """
[
	{
		"host": {
			"ip": ":str:35.204.138.88",
			"port": 30000
		},
		"serializer": "network.peer",
		"version": 100
	}
]
"""

private let goodJsonNodes = """
[
	{
		"host": {
			"ip": ":str:35.204.138.88",
			"port": 30000
		},
		"serializer": "network.peer",
		"system": {
			"agent": {
				"name": ":str:/Radix:/2700000",
				"protocol": 100,
				"version": 2700000
			},
			"clock": 27,
			"commitment": ":hsh:bcd8840700000000000000000000000000000000000000000000000000000000",
			"key": ":byt:AzxyPYCRLbn/V67CxfB0YJ/7t5JJprYsnJw5PPCanO/E",
			"nid": ":uid:cdab1e85a8253e0037a52fba4b5d3c16",
			"planck": 25926315,
			"port": 30000,
			"serializer": "api.system",
			"shards": {
				"high": 9223372036854775807,
				"low": -9223372036854775808
			},
			"version": 100
		},
		"version": 100
	}
]

"""
