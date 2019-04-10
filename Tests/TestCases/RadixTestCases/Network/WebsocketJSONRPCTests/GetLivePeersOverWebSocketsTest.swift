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

class GetLivePeersOverWebSocketsTest: WebsocketTest {
    
    func testLivePeersOverWS() {
        guard let apiClient = makeApiClient() else { return }
        let livePeersObservable: Observable<[NodeRunnerData]> = apiClient.livePeers(communcation: .websocket)
        
        let livePeers: [NodeRunnerData] = try! livePeersObservable.take(1).toBlocking(timeout: 1).first()!
        
        XCTAssertEqual(livePeers.count, 1)
        let livePeer = livePeers[0]
        XCTAssertTrue(livePeer.ipAddress.looksLikeAnIPAddress)
    }
}
