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

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking

//class SubmitAtomOverWebSocketsTest: LocalhostNodeTest {
//    
//    private let magic: Magic = 63799298
//    private let powWorker = DefaultProofOfWorkWorker()
//    
//    private var atom: Atom!
//    private lazy var identity = RadixIdentity(magic: magic)
//    
//    override func setUp() {
//        super.setUp()
//        
//        let address = Address(magic: magic, publicKey: identity.publicKey)
//        
//        let createTokenAction = try! CreateTokenAction(
//            creator: address,
//            name: "Cyon",
//            symbol: "CCC",
//            description: "Cyon Crypto Coin is the worst shit coin",
//            supply: .fixed(to: 30)
//        )
// 
//        let particleGroups = DefaultCreateTokenActionToParticleGroupsMapper().particleGroups(for: createTokenAction)
// 
//        atom = Atom(particleGroups: particleGroups)
//    }
//    
//    func testTokenDefinitionParticle() {
//        guard let pow = doPow(worker: powWorker, atom: atom, magic: magic) else { return }
//        let atowWithPOW = try! AtomWithFee(atomWithoutPow: atom, proofOfWork: pow)
//        let unsignedAtom = try! UnsignedAtom(atomWithPow: atowWithPOW)
//        let signedAtom = try! identity.sign(atom: unsignedAtom)
//        
//        guard let rpcClient = makeRpcClient() else { return }
//        guard let atomSubscriptions = rpcClient.submit(
//            atom: signedAtom,
//            subscriberId: SubscriptionIdIncrementingGenerator.next()
//        ).blockingArrayTakeFirst(2) else { return }
//        
//        XCTAssertEqual(atomSubscriptions.count, 2)
//        let as1 = atomSubscriptions[0]
//        let as2 = atomSubscriptions[1]
//        XCTAssertTrue(as1.isStartOrCancel)
//        XCTAssertTrue(as2.isUpdate)
//
//        let u1 = as2.update!.subscriptionFromSubmissionsUpdate!
//        XCTAssertEqual(u1.value, .stored)
//    }
//}
