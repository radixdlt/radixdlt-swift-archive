//
//  GetUniverseOverWS.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking

class GetUniverseOverWebSocketsTest: WebsocketTest {
    
    func testGetUniverse() {
        guard let rpcClient = makeRpcClient() else { return }
        guard let universeConfig = rpcClient.getUniverseConfig().blockingTakeFirst() else { return }
        
        XCTAssertEqual(universeConfig.description, "The Radix development Universe")
        XCTAssertEqual(universeConfig.magic, 63799298)
    }
    
}

