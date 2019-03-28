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
class WebSocketsGetLivePeersTest: XCTestCase {

    private let bag = DisposeBag()
    
    override func setUp() {
        super.setUp()
    }
    
    func testLivePeersOverWS() {
        let livePeersExp = XCTestExpectation(description: "Live Peers")
        
        let apiClient = DefaultAPIClient(nodeDiscovery: NodeDiscoveryHardCoded(Node.localhost(port: 8080)))
   
        let livePeers = apiClient.livePeers(communcation: .websocket)
            
        livePeers.subscribe(onNext: { nodeRunners in
            XCTAssertFalse(nodeRunners.isEmpty)
            XCTAssertEqual(nodeRunners[0].ipAddress.components(separatedBy: ".").count , 4)
            livePeersExp.fulfill()
        }, onError: {
            XCTFail("⚠️ Error: \($0)")
            livePeersExp.fulfill()
        }).disposed(by: bag)
        

        wait(for: [livePeersExp], timeout: 1)
        
    }
    
}
