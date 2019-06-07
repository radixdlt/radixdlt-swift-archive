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
    
    private let magic: Magic = 63799298
    private let powWorker = DefaultProofOfWorkWorker()
    
    private var atom: Atom!
    private lazy var identity = RadixIdentity(magic: magic)
    
    override func setUp() {
        super.setUp()
        
        let address = Address(magic: magic, publicKey: identity.publicKey)
        
        let createTokenAction = try! CreateTokenAction(
            creator: address,
            name: "Cyon",
            symbol: "CCC",
            description: "Cyon Crypto Coin is the worst shit coin",
            supply: .fixed(to: 30)
        )
 
        let particleGroups = DefaultCreateTokenActionToParticleGroupsMapper().particleGroups(for: createTokenAction)
 
        atom = Atom(particleGroups: particleGroups)
    }
    
    func testTokenDefinitionParticle() {
        guard let pow = doPow(worker: powWorker, atom: atom, magic: magic) else { return }
        let atowWithPOW = try! ProofOfWorkedAtom(atomWithoutPow: atom, proofOfWork: pow)
        let unsignedAtom = try! UnsignedAtom(atomWithPow: atowWithPOW)
        let signedAtom = try! identity.sign(atom: unsignedAtom)
        
        guard let rpcClient = makeRpcClient() else { return }
        guard let atomSubscriptions = rpcClient.submit(
            atom: signedAtom,
            subscriberId: SubscriptionIdIncrementingGenerator.next()
        ).blockingArrayTakeFirst(2) else { return }
        
        XCTAssertEqual(atomSubscriptions.count, 2)
        let as1 = atomSubscriptions[0]
        let as2 = atomSubscriptions[1]
        XCTAssertTrue(as1.isStartOrCancel)
        XCTAssertTrue(as2.isUpdate)

        let u1 = as2.update!.subscriptionFromSubmissionsUpdate!
        XCTAssertEqual(u1.value, .stored)
    }
}
