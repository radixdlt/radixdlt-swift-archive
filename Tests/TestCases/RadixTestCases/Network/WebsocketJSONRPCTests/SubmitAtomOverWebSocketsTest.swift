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
    
    private var signedAtom: SignedAtom!
    
    override func setUp() {
        super.setUp()
        
        let identity = RadixIdentity()
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
        
        let atom = Atom(particleGroups: [
            ParticleGroup([
                tokenDefinitionParticle.withSpin(),
                unallocated.withSpin()
                ])
            ])
        
        let atowWithPOW = try! atom.withProofOfWork(magic: magic)
        self.signedAtom = try! identity.sign(atom: UnsignedAtom(atowWithPOW))
    }
    
    func testTokenDefinitionParticle() {
        guard let rpcClient = makeRpcClient() else { return }
        guard let atomSubscriptions = rpcClient.submitAtom(signedAtom.atom).blockingArrayTakeFirst(2) else { return }
        
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
        amount: Amount,
        address: Address,
        symbol: Symbol,
        tokenAddress: Address? = nil,
        permissions: TokenPermissions = .default,
        granularity: Granularity = .default,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck()
        ) {
        
        let tokenDefinitionReference = TokenDefinitionReference(
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
