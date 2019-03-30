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
        guard let apiClient = makeApiClient() else { return }
        let universeConfig = try! apiClient.getUniverse().take(1).toBlocking(timeout: 1).first()!
        XCTAssertEqual(universeConfig.description, "The Radix development Universe")
    }
    
}

