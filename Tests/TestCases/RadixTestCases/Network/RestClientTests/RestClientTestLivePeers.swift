//
//  RestClientTestLivePeers.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift

// Commented out since these tests will fail if we are not connected to localhost

//class RestClientTestLivePeersTest: XCTestCase {
//    private let bag = DisposeBag()
//    private let restClient = DefaultRESTClient(baseURL: Enviroment.localhost.baseURL.appendingPathComponent("api"))
//
//    override func setUp() {
//        super.setUp()
//    }
//
//    func testRestLivePeers() {
//        let expectation = XCTestExpectation(description: "rest client")
//
//        restClient.request(router: NodeRouter.livePeers, decodeAs: [NodeRunnerData].self).subscribe(onSuccess: { nodeRunners in
//            XCTAssertFalse(nodeRunners.isEmpty)
//            XCTAssertEqual(nodeRunners[0].ipAddress.components(separatedBy: ".").count , 4)
//            expectation.fulfill()
//        }, onError: {
//            XCTFail("Error: \($0)")
//            expectation.fulfill()
//        }).disposed(by: bag)
//
//        wait(for: [expectation], timeout: 10)
//    }
//
//}
