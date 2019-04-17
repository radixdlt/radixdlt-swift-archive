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
    
    // Instable test, will probably be removed, dependent on https://sunstone.radixdlt.com/node-finder
    func testNodeDiscoveryViaStaticIP() {
        // IP addresses from Node Finder
        let nodeDiscovery = try! NodeDiscoveryHardCoded(hosts: ["35.204.144.151", "35.204.205.109"])
        guard let nodeArray = nodeDiscovery.loadNodes().blockingTakeFirst() else { return }
        XCTAssertEqual(nodeArray.count, 2)
        let nodeZero = nodeArray[0]
        XCTAssertEqual(nodeZero.httpUrl.url.absoluteString, "https://35.204.144.151:443/api")
        XCTAssertEqual(nodeZero.websocketsUrl.url.absoluteString, "wss://35.204.144.151:443/rpc")
        let nodeOne = nodeArray[1]
        XCTAssertEqual(nodeOne.httpUrl.url.absoluteString, "https://35.204.205.109:443/api")
        XCTAssertEqual(nodeOne.websocketsUrl.url.absoluteString, "wss://35.204.205.109:443/rpc")
        
    }
    
    func testLocalHost() {
        let nodeDiscovery: NodeDiscoveryHardCoded = .localhost
        guard let nodeArray = nodeDiscovery.loadNodes().blockingTakeFirst() else { return }
        XCTAssertEqual(nodeArray.count, 1)
        let node = nodeArray[0]
        XCTAssertEqual(node.httpUrl.url.absoluteString, "http://localhost:8080/api")
        XCTAssertEqual(node.websocketsUrl.url.absoluteString, "ws://localhost:8080/rpc")
    }
    
    func testBadNetworkDetails() {
        
        let subject = PublishSubject<NodeNetworkDetails>()
        
        let nodeDiscovery = try! NodeDiscoveryHardCoded(
            hosts: [Host.local()],
            networkDetailsRequestingFactory: { _ in
                return MockedNetworkDetailsRequester(subject: subject)
            }
        )
        subject.onError(MockedError.incompatibleJson)
        XCTAssertThrowsError(try nodeDiscovery.loadNodes().toBlocking(timeout: 1).first(), "Should throw error when receiving error from API") { error in
            guard let networkError = error as? MockedError else {
                return XCTFail("Wrong error")
            }
            XCTAssertEqual(networkError, MockedError.incompatibleJson)
        }
    }
    
    func testNodeFinder() {
        let nodeFinder: NodeFinder = .sunstone
        guard let nodes = nodeFinder.loadNodes().blockingTakeFirst() else { return }
        XCTAssertFalse(nodes.isEmpty)
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

struct MockedNetworkDetailsRequester: NodeNetworkDetailsRequesting {
    private let single: SingleWanted<NodeNetworkDetails>
    init(_ single: SingleWanted<NodeNetworkDetails>) {
        self.single = single
    }
    init(subject: PublishSubject<NodeNetworkDetails>) {
        self.init(subject.asObservable())
    }
    func networkDetails() -> SingleWanted<NodeNetworkDetails> {
        return single
    }
}

private enum MockedError: Swift.Error, Equatable {
    case incompatibleJson
}

//final class MockedHTTPClient: HTTPClient {
//    func request<D>(router: Router, decodeAs type: D.Type) -> Observable<D> where D : Decodable {
//        abstract
//    }
//
//    func loadContent(of page: String) -> SingleWanted<String> {
//        abstract
//    }
//}
//
//final class MockedRestClient: RESTClient, HTTPClientOwner {
//    let httpClient: HTTPClient
//    init(httpClient: HTTPClient) {
//        self.httpClient = httpClient
//    }
//}
