//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import XCTest
@testable import RadixSDK
import RxSwift
import Combine

class GetTokenBalanceTests: LocalhostNodeTest {
        
//    func testGetTokenBalance() {
//        // GIVEN
//        // a Radix Application
//        let (replaySubject, application) = applicationWithMockedSubscriber()
//
//        func atomObservation(amount: PositiveAmount, spin: Spin, isHead: Bool = false) -> AtomObservation {
//            return AtomObservation(
//                atom: atomTransferrable(amount, address: xrdAddress, spin: spin),
//                isHead: isHead)
//        }
//
//        // WHEN
//        // The node returns an atom with 7 consumable (spin up) XRD
//        replaySubject.onNext([
//            atomObservation(amount: 7, spin: .up, isHead: true)
//        ])
//
//        guard let balance = application.myBalanceOfNativeTokensOrZero().blockingTakeFirst() else { return }
//
//        XCTAssertEqual(
//            balance.balance.amount,
//            7,
//            // THEN
//            "Xrd balance is 7"
//        )
//    }

//    func testThatOrderOfAtomsDoesNotMatterForBalanceCalculation() {
//        let identity = RadixIdentity()
//        let myAddress = identity.address
//
//        let (replaySubject, application) = applicationWithMockedSubscriber(identity: identity, bufferSize: 3)
//
//        func atomObservation(amount: PositiveAmount, spin: Spin) -> AtomObservation {
//            return
//
//        replaySubject.onNext([
//           atomObservation(amount: 1, spin: .down),
//           atomObservation(amount: 1, spin: .up),
//           atomObservation(amount: 1, spin: .up, isHead: true)
//        ])
//
//        guard let downUpUpBalance = application.getMyBalance(of: xrd).blockingTakeFirst() else { return }
//
//        replaySubject.onNext([
//            atomObservation(amount: 1, spin: .up),
//            atomObservation(amount: 1, spin: .down),
//            atomObservation(amount: 1, spin: .up, isHead: true)
//            ])
//
//        guard let upDownUpBalance = application.getMyBalance(of: xrd).blockingTakeFirst() else { return }
//
//        XCTAssertAllEqual(
//            downUpUpBalance.balance.amount,
//            upDownUpBalance.balance.amount,
//            1
//        )
//    }
    
//    func testIncrease() {
//        let alice = RadixIdentity()
//        let myAddress = alice.address
//        let (replaySubject, application) = applicationWithMockedSubscriber(identity: alice)
//
//        func atomObservation(amount: PositiveAmount, spin: Spin, isHead: Bool = false) -> AtomObservation {
//            return AtomObservation(
//                atom: atomTransferrable(amount, address: myAddress, spin: spin),
//                isHead: isHead)
//        }
//
//        replaySubject.onNext([
//            atomObservation(amount: 0, spin: .up, isHead: true)
//        ])
//
//        guard let aliceStartBalance = application.getMyBalance(of: xrd).blockingTakeFirst() else { return }
//
//        XCTAssertEqual(aliceStartBalance.balance.amount, 0)
//
//        replaySubject.onNext([
//            atomObservation(amount: 3, spin: .up, isHead: true)
//        ])
//
//        guard let aliceNewBalance = application.getMyBalance(of: xrd).blockingTakeFirst() else { return }
//
//        XCTAssertEqual(aliceNewBalance.balance.amount, 3)
//    }
 
}

//private extension GetTokenBalanceTests {
//    func applicationWithMockedSubscriber(identity: RadixIdentity = RadixIdentity(), bufferSize: Int = 1) -> (subject: ReplaySubject<[AtomObservation]>, app: RadixApplicationClient) {
//        let replaySubject = ReplaySubject<[AtomObservation]>.create(bufferSize: bufferSize)
//
//        let application = RadixApplicationClient(
//            nodeSubscriber: MockedNodeSubscribing(replaySubject: replaySubject),
//            nodeUnsubscriber: MockedNodeUnsubscribing(),
//            nodeSubmitter: MockedNodeSubmitting(),
//            identity: identity,
//            magic: magic
//        )
//
//        return (subject: replaySubject, app: application)
//    }
//}
//
//private let xrdAddress: Address = "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor"
//private let xrd = ResourceIdentifier(address: xrdAddress, name: "XRD")
//
//private func atomTransferrable(_ amount: PositiveAmount, address: Address, spin: Spin) -> Atom {
//    let particle = TransferrableTokensParticle(
//        amount: amount,
//        address: address,
//        tokenDefinitionReference: xrd
//    )
//    return Atom(particle: particle, spin: spin)
//}
//
//private let magic: Magic = 63799298
//
//private extension RadixIdentity {
//    init() {
//        self.init(magic: magic)
//    }
//}
