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

class GetTokenBalanceTests: WebsocketTest {
    
    func testGetTokenBalance() {
        // GIVEN
        // a Radix Application
        let (replaySubject, application) = applicationWithMockedSubscriber()
        
        func atomUpdate(amount: PositiveAmount, spin: Spin, isHead: Bool = false) -> AtomUpdate {
            return AtomUpdate(
                atom: atomTransferrable(amount, address: xrdAddress, spin: spin),
                isHead: isHead)
        }
        
        // WHEN
        // The node returns an atom with 7 consumable (spin up) XRD
        replaySubject.onNext([
            atomUpdate(amount: 7, spin: .up, isHead: true)
        ])
        
        guard let balance = application.getBalances(for: xrdAddress, ofToken: xrd).blockingTakeFirst() else { return }

        XCTAssertEqual(
            balance.balance.amount,
            7,
            // THEN
            "Xrd balance is 7"
        )
    }

    func testThatOrderOfAtomsDoesNotMatterForBalanceCalculation() {
        let identity = RadixIdentity()
        let myAddress = identity.address

        let (replaySubject, application) = applicationWithMockedSubscriber(identity: identity, bufferSize: 3)
        
        func atomUpdate(amount: PositiveAmount, spin: Spin, isHead: Bool = false) -> AtomUpdate {
            return AtomUpdate(
                atom: atomTransferrable(amount, address: myAddress, spin: spin),
                isHead: isHead)
        }
        
        replaySubject.onNext([
           atomUpdate(amount: 1, spin: .down),
           atomUpdate(amount: 1, spin: .up),
           atomUpdate(amount: 1, spin: .up, isHead: true)
        ])
        
        guard let downUpUpBalance = application.getMyBalance(of: xrd).blockingTakeFirst() else { return }
        
        replaySubject.onNext([
            atomUpdate(amount: 1, spin: .up),
            atomUpdate(amount: 1, spin: .down),
            atomUpdate(amount: 1, spin: .up, isHead: true)
            ])

        guard let upDownUpBalance = application.getMyBalance(of: xrd).blockingTakeFirst() else { return }

        XCTAssertAllEqual(
            downUpUpBalance.balance.amount,
            upDownUpBalance.balance.amount,
            1
        )
    }
    
    func testIncrease() {
        let alice = RadixIdentity()
        let myAddress = alice.address
        let (replaySubject, application) = applicationWithMockedSubscriber(identity: alice)
        
        func atomUpdate(amount: PositiveAmount, spin: Spin, isHead: Bool = false) -> AtomUpdate {
            return AtomUpdate(
                atom: atomTransferrable(amount, address: myAddress, spin: spin),
                isHead: isHead)
        }
        
        replaySubject.onNext([
            atomUpdate(amount: 0, spin: .up, isHead: true)
        ])
        
        guard let aliceStartBalance = application.getMyBalance(of: xrd).blockingTakeFirst() else { return }
        
        XCTAssertEqual(aliceStartBalance.balance.amount, 0)
        
        replaySubject.onNext([
            atomUpdate(amount: 3, spin: .up, isHead: true)
        ])
        
        guard let aliceNewBalance = application.getMyBalance(of: xrd).blockingTakeFirst() else { return }
        
        XCTAssertEqual(aliceNewBalance.balance.amount, 3)
    }
 
}

private extension GetTokenBalanceTests {
    func applicationWithMockedSubscriber(identity: RadixIdentity = RadixIdentity(), bufferSize: Int = 1) -> (subject: ReplaySubject<[AtomUpdate]>, app: DefaultRadixApplicationClient) {
        let replaySubject = ReplaySubject<[AtomUpdate]>.create(bufferSize: bufferSize)
        
        let application = DefaultRadixApplicationClient(
            nodeSubscriber: MockedNodeSubscribing(replaySubject: replaySubject),
            nodeUnsubscriber: MockedNodeUnsubscribing(),
            nodeSubmitter: MockedNodeSubmitting(),
            identity: identity,
            magic: magic
        )
        
        return (subject: replaySubject, app: application)
    }
}

private let xrdAddress: Address = "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor"
private let xrd = ResourceIdentifier(address: xrdAddress, name: "XRD")

private func atomTransferrable(_ amount: PositiveAmount, address: Address, spin: Spin) -> Atom {
    let particle = TransferrableTokensParticle(
        amount: amount,
        address: address,
        tokenDefinitionReference: xrd
    )
    return Atom(particle: particle, spin: spin)
}

private let magic: Magic = 63799298

private extension RadixIdentity {
    init() {
        self.init(magic: magic)
    }
}
