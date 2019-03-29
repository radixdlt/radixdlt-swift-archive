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

class GetUniverseOverWS: XCTestCase {
        
    private let bag = DisposeBag()
    
    func testLivePeersOverWS() {
        let expectation = XCTestExpectation(description: "Universe")
        
        let apiClient = DefaultAPIClient(
            nodeDiscovery: Node.localhost(port: 8080)
        )
        
        let universeConfig = apiClient.getUniverse()
        
        universeConfig.subscribe(onNext: { universeConfig in
            XCTAssertEqual(universeConfig.description, "The Radix development Universe")
            expectation.fulfill()
        }, onError: {
            XCTFail("⚠️ Error: \($0)")
            expectation.fulfill()
        }).disposed(by: bag)
        
        
        wait(for: [expectation], timeout: 1)
        
    }
}

