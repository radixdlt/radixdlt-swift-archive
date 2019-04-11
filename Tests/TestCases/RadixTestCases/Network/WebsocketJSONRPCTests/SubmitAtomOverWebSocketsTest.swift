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
    
    func testTokenDefinitionParticle() {
        guard let apiClient = makeApiClient() else { return }
        
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
        
        let signedAtom = try! identity.sign(atom: UnsignedAtom(atowWithPOW))
        
        let submitObservable = apiClient.submit(atom: signedAtom.atom)
        
        let atomSubscriptions: [AtomSubscription]
        do {
             atomSubscriptions = try submitObservable.take(2).toBlocking(timeout: 1).toArray()
        } catch { return XCTFail("failed to send atom, error: \(error)") }

        XCTAssertEqual(atomSubscriptions.count, 2)
        let as1 = atomSubscriptions[0]
        let as2 = atomSubscriptions[1]
        XCTAssertTrue(as1.isStart)
        XCTAssertTrue(as2.isUpdate)

        let u1 = as2.update!.subscriptionFromSubmissionsUpdate!
        
        XCTAssertNotEqual(atom.hashId, signedAtom.atom.hashId)

        XCTAssertEqual(u1.value, .stored, "ValidationError, Atom signed with identity having address: \(address), publicKey: \(identity.publicKey)")
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
