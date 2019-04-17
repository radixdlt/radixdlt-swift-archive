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
