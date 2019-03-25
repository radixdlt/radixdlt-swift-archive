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
class NodeFinderTest: XCTestCase {
    private let bag = DisposeBag()
    private let nodeFinder =  NodeFinder(enviroment: .localhost)
    
    override func setUp() {
        super.setUp()
    }
    
    func testNodeFinder() {
        let expectation = XCTestExpectation(description: "Node finder localhost")
        
        nodeFinder.getSeed().subscribe(onNext: { nodes in
            expectation.fulfill()
        }, onError: {
            XCTFail("Error: \($0)")
            expectation.fulfill()
        }).disposed(by: bag)
        
        wait(for: [expectation], timeout: 10)
    }
    
}
