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

extension AtomQuerying {
    func subscribe(to address: Address) -> Observable<AtomSubscription> {
        return subscribe(to: address, subscriberId: SubscriptionIdIncrementingGenerator.next())
    }
}

class GetAtomsOverWebSocketsTest: WebsocketTest {
    
    func testGetAtomsOverWebsockets() {
        guard let rpcClient = makeRpcClient() else { return }
        guard let atomSubscriptions = rpcClient.subscribe(to: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor").blockingArrayTakeFirst(3, timeout: 5) else { return }
        
        XCTAssertEqual(atomSubscriptions.count, 3)
        let as1 = atomSubscriptions[0]
        let as2 = atomSubscriptions[1]
        let as3 = atomSubscriptions[2]
        XCTAssertTrue(as1.isStart)
        XCTAssertTrue(as2.isUpdate)
        XCTAssertTrue(as3.isUpdate)
        
        let u1 = as2.update!.subscriptionUpdate!
        let u2 = as3.update!.subscriptionUpdate!
        
        XCTAssertFalse(u1.isHead)
        XCTAssertFalse(u1.atomEvents.isEmpty)
        let atom = u1.atomEvents[0].atom
        XCTAssertNotNil(atom.particlesOfType(UnallocatedTokensParticle.self, spin: .up))
        XCTAssertTrue(u2.isHead)
        XCTAssertTrue(u2.atomEvents.isEmpty)
    }
}

