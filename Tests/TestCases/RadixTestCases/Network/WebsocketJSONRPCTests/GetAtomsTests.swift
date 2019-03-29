//
//  GetAtomsTests.swift
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

class GetAtomsTests: XCTestCase {
    
    private let bag = DisposeBag()
    

    
//    func testGetAtoms() {
//        let apiClient = DefaultAPIClient(nodeDiscovery: NodeDiscoveryHardCoded(Node.localhost(port: 8080)))
//        let atomSubscriptionsObservable: Observable<AtomSubscription> = apiClient.pull(from: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor")
//        do {
//            let atomSubscriptions: [AtomSubscription] = try atomSubscriptionsObservable.toBlocking(timeout: 2).toArray()
//            XCTAssertEqual(atomSubscriptions.count, 3)
//        } catch {
//            XCTFail("Error: \(error)")
//        }
//    }
    
    func testGetAtoms() {
        let expectation = XCTestExpectation(description: "Get Atoms")
        
        let apiClient = DefaultAPIClient(
            nodeDiscovery: Node.localhost(port: 8080)
        )
        
        let atomSubscriptions = apiClient.pull(from: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor")
        
        atomSubscriptions.subscribe(onNext: { atomSubscription in
            switch atomSubscription {
            case .start(let start): XCTAssertTrue(start.success)
            case .cancel(let cancel): XCTAssertTrue(cancel.success)
            case .update(let update):
                if update.isHead {
                    XCTAssertTrue(update.atomEvents.isEmpty)
                } else {
                    XCTAssertFalse(update.atomEvents.isEmpty)
                    let atomEvent = update.atomEvents[0]
                    switch atomEvent.type {
                    case .store: XCTAssert(true)
                    case .delete: XCTFail("Expected `store`")
                    }
                    let atom = atomEvent.atom
                    XCTAssertFalse(atom.particleGroups.isEmpty)
                }
            }
            expectation.fulfill()
        }, onError: {
            XCTFail("⚠️ Error: \($0)")
            expectation.fulfill()
        }).disposed(by: bag)
        
        
        wait(for: [expectation], timeout: 1)
        
    }
}

