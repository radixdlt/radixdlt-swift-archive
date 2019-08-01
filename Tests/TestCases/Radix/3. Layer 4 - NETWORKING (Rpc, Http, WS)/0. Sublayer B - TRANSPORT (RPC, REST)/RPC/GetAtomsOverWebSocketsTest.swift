/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking

extension AtomsByAddressSubscribing {
    func subscribe(to address: Address) -> Observable<AtomSubscription> {
        return subscribe(to: address, subscriberId: SubscriptionIdIncrementingGenerator.next())
    }
}

class GetAtomsOverWebSocketsTest: LocalhostNodeTest {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testGetAtomsOverWebsockets() {
        guard let rpcClient = makeRpcClient() else { return }
        guard let atomSubscriptions = rpcClient.subscribe(to: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor").blockingArrayTakeFirst(3, timeout: 3) else { return }
        
        XCTAssertEqual(atomSubscriptions.count, 3)
        let as1 = atomSubscriptions[0]
        let as2 = atomSubscriptions[1]
        let as3 = atomSubscriptions[2]
        XCTAssertTrue(as1.isStartOrCancel)
        XCTAssertTrue(as2.isUpdate)
        XCTAssertTrue(as3.isUpdate)
        
        let u1 = as2.update!.subscriptionUpdate!
        let u2 = as3.update!.subscriptionUpdate!
        
        XCTAssertFalse(u1.isHead)
        XCTAssertFalse(u1.atomEvents.isEmpty)
        let atom = u1.atomEvents[0].atom
        XCTAssertNotNil(atom.particlesOfType(UnallocatedTokensParticle.self, spin: .up))
        XCTAssertTrue(u2.isHead)
        XCTAssertTrue(u2.atomEvents.isEmpty)
    }
}

