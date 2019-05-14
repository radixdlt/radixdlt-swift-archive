//
//  GetTokenBalanceTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK
import RxSwift

class GetTokenBalanceTests: XCTestCase {

    func testThatOrderOfAtomsDoesNotMatterForBalanceCalculation() {
        let identity = RadixIdentity(private: 1, magic: 1)
        let myAddress = identity.address

        let atomCount = 3
        let replaySubject = ReplaySubject<[AtomUpdate]>.create(bufferSize: atomCount)
   
        let mockedSubscribing = MockedNodeSubscribing(replaySubject: replaySubject)
        
        let application = DefaultRadixApplicationClient(
            nodeSubscriber: mockedSubscribing,
            nodeUnsubscriber: MockedNodeUnsubscribing(),
            nodeSubmitter: MockedNodeSubmitting(),
            identity: identity
        )
        
        func atomUpdate(amount: PositiveAmount, spin: Spin, isHead: Bool = false) -> AtomUpdate {
            return AtomUpdate(
                action: .store,
                atom: atomTransferrable(amount, address: myAddress, spin: spin),
                isHead: isHead)
        }
        
        replaySubject.onNext([
           atomUpdate(amount: 1, spin: .down),
           atomUpdate(amount: 1, spin: .up),
           atomUpdate(amount: 1, spin: .up, isHead: true)
        ])
        
        guard let downUpUpBalance = application.getMyBalance(of: xrd).blockingTakeLast() else { return }
        
        replaySubject.onNext([
            atomUpdate(amount: 1, spin: .up),
            atomUpdate(amount: 1, spin: .down),
            atomUpdate(amount: 1, spin: .up, isHead: true)
            ])

        guard let upDownUpBalance = application.getMyBalance(of: xrd).blockingTakeLast() else { return }

        XCTAssertAllEqual(
            downUpUpBalance.amount,
            upDownUpBalance.amount,
            1
        )
    }
}

private let xrdAddress: Address = "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei"
private let xrd = ResourceIdentifier(address: xrdAddress, name: "XRD")

private func atomTransferrable(_ amount: PositiveAmount, address: Address, spin: Spin) -> Atom {
    let particle = TransferrableTokensParticle(
        amount: amount,
        address: address,
        tokenDefinitionReference: xrd
    )
    return Atom(particle: particle, spin: spin)
}
