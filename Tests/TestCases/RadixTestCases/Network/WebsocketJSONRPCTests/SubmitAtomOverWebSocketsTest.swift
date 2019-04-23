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
    
    private var atom: Atom!
    private let identity = RadixIdentity()
    
    override func setUp() {
        super.setUp()
        
        let address = Address(magic: magic, publicKey: identity.publicKey)
        
        let tokenDefinitionParticle = TokenDefinitionParticle(
            symbol: "CCC",
            name: "Cyon",
            description: "Cyon Crypto Coin is the worst shit coin",
            address: address
        )
        
        let unallocated = UnallocatedTokensParticle(
            amount: .maxValue256Bits,
            tokenDefinitionReference: tokenDefinitionParticle.tokenDefinitionReference
        )
        
//        let rriParticle = ResourceIdentifierParticle(resourceIdentifier: <#T##ResourceIdentifier#>, nonce: <#T##Nonce#>)
        
        atom = Atom(particleGroups: [
            ParticleGroup([
                tokenDefinitionParticle.withSpin(),
                unallocated.withSpin()
                ])
            ])
    }
    
    func testTokenDefinitionParticle() {
        guard let pow = ProofOfWork.work(atom: atom, magic: magic) else { return XCTFail("timeout") }
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
        XCTAssertTrue(as1.isStart)
        XCTAssertTrue(as2.isUpdate)

        let u1 = as2.update!.subscriptionFromSubmissionsUpdate!
        XCTAssertEqual(u1.value, .stored)
    }
}


// MARK: - Convenience Init
extension TransferrableTokensParticle {
    init(
        amount: PositiveAmount,
        address: Address,
        symbol: Symbol,
        tokenAddress: Address? = nil,
        permissions: TokenPermissions = .default,
        granularity: Granularity = .default,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck()
        ) {
        
        let tokenDefinitionReference = ResourceIdentifier(
            address: tokenAddress ?? address,
            symbol: symbol
        )
        
        self.init(
            amount: amount,
            address: address,
            tokenDefinitionReference: tokenDefinitionReference,
            permissions: permissions,
            granularity: granularity,
            nonce: nonce,
            planck: planck
        )
    }
}
