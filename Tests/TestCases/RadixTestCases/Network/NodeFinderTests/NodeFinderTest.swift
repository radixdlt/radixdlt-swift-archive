//
//  NodeFinderTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift

// Commented out since these tests will fail if we are not connected to localhost

//private let somePort = 1234
//class NodeFinderTest: XCTestCase {
//    private let bag = DisposeBag()
//    private let nodeFinder = NodeFinder(baseURL: .localhost, port: somePort)
//
//    override func setUp() {
//        super.setUp()
//    }
//
//    func testNodeFinder() {
//        let expectation = XCTestExpectation(description: "Node finder localhost")
//
//        nodeFinder.loadNodes().subscribe(
//            onNext: { node in
//                XCTAssertEqual(node[0].url.absoluteString, "ws://127.0.0.1:\(somePort)/rpc")
//                expectation.fulfill()
//        }, onError: {
//            XCTFail("Error: \($0)")
//            expectation.fulfill()
//        }).disposed(by: bag)
//
//        wait(for: [expectation], timeout: 10)
//    }
//
//}
