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

    func testNodeFinder() {
        let nodeFinder: NodeFinder = .sunstone
        guard let nodes = try? nodeFinder.loadNodes().take(1).toBlocking(timeout: 1).first() else {
            return XCTFail("no nodes")
        }
        XCTAssertFalse(nodes.isEmpty)
    }
    
    func testLocalHost() {
        let nodeDiscovery: NodeDiscoveryHardCoded = .localhost
        guard let nodes = try? nodeDiscovery.loadNodes().take(1).toBlocking(timeout: 5).first() else {
            return XCTFail("no nodes")
        }
        XCTAssertFalse(nodes.isEmpty)
    }
    
}
