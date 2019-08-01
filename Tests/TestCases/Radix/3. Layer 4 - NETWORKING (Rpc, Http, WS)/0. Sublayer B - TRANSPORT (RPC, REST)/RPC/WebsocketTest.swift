//
//  LocalhostNodeTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking


//extension NodeDiscoveryHardCoded {
//    static var localhost: NodeDiscoveryHardCoded {
//        do {
//            return try NodeDiscoveryHardCoded(hosts: [Host.local()], universeConfig: UniverseConfig.localnet, strategyIfUnsuitable: .throwError)
//        } catch {
//            incorrectImplementation("Error: \(error)")
//        }
//    }
//}
//
//extension RPCClientsRetainer {
//    class func futureRpcClient(nodeDiscovery: NodeDiscovery) -> Observable<RPCClient> {
//        return nodeDiscovery.loadNodes().map { nodes -> RPCClient in
//            let node = nodes[0]
//            return RPCClientsRetainer.rpcClient(node: node)
//        }
//    }
//}

//class WebsocketTest: XCTestCase {
//
//    override func invokeTest() {
//        guard isConnectedToLocalhost() else { return }
//        super.invokeTest()
//    }
//
//    func makeRpcClient(
//        nodeDiscovery: NodeDiscovery = NodeDiscoveryHardCoded.localhost,
//        timeout: TimeInterval = 1,
//        failOnTimeout: Bool = true,
//        _ function: String = #function, _ file: String = #file
//        ) -> RPCClient? {
//        return RPCClientsRetainer.futureRpcClient(nodeDiscovery: nodeDiscovery).blockingTakeFirst(timeout: timeout, failOnTimeout: failOnTimeout, failOnNil: true, function: function, file: file)
//    }
//}

class LocalhostNodeTest: XCTestCase {

    override func invokeTest() {
        guard isConnectedToLocalhost() else { return }
        super.invokeTest()
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
}
