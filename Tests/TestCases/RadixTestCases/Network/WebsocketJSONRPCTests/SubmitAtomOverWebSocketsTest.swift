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
    
    func testTokenDefinitionParticle() {
        guard let apiClient = makeApiClient() else { return }
        
        let identity = RadixIdentity()
        let address = Address(publicKey: identity.publicKey)
        
        let tokenDefinitionParticle = TokenDefinitionParticle(
            symbol: "CCC",
            name: "Cyon",
            description: "Cyon Crypto Coin is the worst shit coin",
            address: address
        )
        
        let mintedTokenParticle = MintedTokenParticle(
            address: address,
            amount: 1000,
            tokenDefinitionReference: tokenDefinitionParticle.tokenDefinitionReference
        )
        
        let atom = try! Atom(particleGroups: [
            tokenDefinitionParticle.withSpin().wrapInGroup(),
            mintedTokenParticle.withSpin().wrapInGroup()
        ]).withProofOfWork(magic: 63799298)
        
        let submitObservable = apiClient.submit(atom: atom)
        
        let atomSubscriptions: [AtomSubscription]
        do {
             atomSubscriptions = try submitObservable.take(2).toBlocking(timeout: 4).toArray()
        } catch { return XCTFail("failed to send atom, error: \(error)") }

        XCTAssertEqual(atomSubscriptions.count, 2)
        let as1 = atomSubscriptions[0]
        let as2 = atomSubscriptions[1]
        XCTAssertTrue(as1.isStart)
        XCTAssertTrue(as2.isUpdate)

        let u1 = as2.update!.subscriptionFromSubmissionsUpdate!

        XCTAssertEqual(u1.value, .stored)
    }
}
