////
//// MIT License
////
//// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
//// 
//// Permission is hereby granted, free of charge, to any person obtaining a copy
//// of this software and associated documentation files (the "Software"), to deal
//// in the Software without restriction, including without limitation the rights
//// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//// copies of the Software, and to permit persons to whom the Software is
//// furnished to do so, subject to the following conditions:
//// 
//// The above copyright notice and this permission notice shall be included in all
//// copies or substantial portions of the Software.
//// 
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//// SOFTWARE.
////
//
//import XCTest
//@testable import RadixSDK
//import RxSwift
//
//class AtomToTransferMapperTests: XCTestCase {
//
//    private let disposeBag = DisposeBag()
//    
//    override func setUp() {
//        super.setUp()
//        continueAfterFailure = false
//    }
//    
//    func testAtomToTransferWithReturn() {
//        
////        let aliceApp = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: AbstractIdentity())
//        
//        
//        
//        let (tokenCreation, aliceCoin) = aliceApp.createToken(supply: .fixed(to: 100))
//        
//        XCTAssertTrue(tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW))
//        
//        let bob = aliceApp.addressOf(account: Account())
//        
//        let atom = try! aliceApp.atomFrom(transaction:
//            Transaction {
//                aliceApp.actionTransferTokens(
//                    identifier: aliceCoin,
//                    to: bob,
//                    amount: 14,
//                    message: "Taxi"
//                )
//            }
//        )
//
//        let atomToTransferMapper = DefaultAtomToTokenTransferMapper()
//        guard let transfers = atomToTransferMapper.mapAtomToActions(atom).blockingTakeFirst() else { return }
//        XCTAssertEqual(transfers.count, 1)
//        XCTAssertEqual(transfers[0].amount, 14)
//        XCTAssertEqual(transfers[0].attachedMessage(), "Taxi")
//        XCTAssertEqual(transfers[0].sender, aliceApp.addressOfActiveAccount)
//        XCTAssertEqual(transfers[0].recipient, bob)
//    }
//
//    func testAtomToTransferWithoutReturn() {
//
////        let aliceApp = RadixApplicationClient(bootstrapConfig: UniverseBootstrap.localhostSingleNode, identity: AbstractIdentity())
//
//        let (tokenCreation, aliceCoin) = aliceApp.createToken(supply: .fixed(to: 100))
//
//        XCTAssertTrue(tokenCreation.blockingWasSuccessfull(timeout: .enoughForPOW))
//
//        let bob = aliceApp.addressOf(account: Account())
//
//        let atom = try! aliceApp.atomFrom(transaction:
//            Transaction {
//                aliceApp.actionTransferTokens(
//                    identifier: aliceCoin,
//                    to: bob,
//                    amount: 100,
//                    message: "Taxi"
//                )
//            }
//        )
//
//        let atomToTransferMapper = DefaultAtomToTokenTransferMapper()
//        guard let transfers = atomToTransferMapper.mapAtomToActions(atom).blockingTakeFirst() else { return }
//        XCTAssertEqual(transfers.count, 1)
//        XCTAssertEqual(transfers[0].amount, 100)
//        XCTAssertEqual(transfers[0].attachedMessage(), "Taxi")
//        XCTAssertEqual(transfers[0].sender, aliceApp.addressOfActiveAccount)
//        XCTAssertEqual(transfers[0].recipient, bob)
//    }
//}
