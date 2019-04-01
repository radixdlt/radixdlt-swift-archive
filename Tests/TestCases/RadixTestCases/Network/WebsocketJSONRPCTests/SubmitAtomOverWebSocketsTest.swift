//
//  SubmitAtomOverWebSocketsTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking

class SubmitAtomOverWebSocketsTest: WebsocketTest {
    
    func testSubmitAtomOverWebsockets() {
        guard let apiClient = makeApiClient() else { return }
        
        let identity = RadixIdentity(private: 1)
        let address = Address(publicKey: identity.publicKey)

        let tokenDefinitionParticle = TokenDefinitionParticle(
            symbol: "CCC",
            name: "Cyon",
            description: "Cyon Crypto Coin is the worst shit coin",
            address: address
        )
        
        let atomToSubmit = try! tokenDefinitionParticle.wrapInAtom()

        let submitObservable = apiClient.submit(atom: atomToSubmit)
        
        let atomSubscriptions: [AtomSubscription]
        do {
             atomSubscriptions = try submitObservable.take(2).toBlocking(timeout: 3).toArray()
        } catch { return XCTFail("failed to send atom, error: \(error)") }

        XCTAssertEqual(atomSubscriptions.count, 3)
        let as1 = atomSubscriptions[0]
        let as2 = atomSubscriptions[1]
        let as3 = atomSubscriptions[2]
        XCTAssertTrue(as1.isStart)
        XCTAssertTrue(as2.isUpdate)
        XCTAssertTrue(as3.isUpdate)

        let u1 = as2.update!
        let u2 = as3.update!

        XCTAssertFalse(u1.isHead)
        XCTAssertFalse(u1.atomEvents.isEmpty)
        let atom = u1.atomEvents[0].atom
        XCTAssertNotNil(atom.particlesOfType(MintedTokenParticle.self, spin: .up))
        XCTAssertTrue(u2.isHead)
        XCTAssertTrue(u2.atomEvents.isEmpty)
    }
}
