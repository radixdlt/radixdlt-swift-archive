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
        guard let livePeers = rpcClient.getLivePeers().blockingTakeFirst() else { return }
        
        XCTAssertEqual(livePeers.count, 1)
        let livePeer = livePeers[0]
        XCTAssertFalse(livePeer.host.ipAddress.isEmpty)
    }
}
