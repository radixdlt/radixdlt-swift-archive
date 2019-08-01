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


//class SigningAtomWithPowResultsInDifferentDsonAsWithoutPowTests: XCTestCase {
//    private let powWorker = DefaultProofOfWorkWorker()
//    private let numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = 1
//    private let magic: Magic = 1337
//    private lazy var identity = RadixIdentity(magic: magic)
//    private lazy var atom: Atom = {
//        let address = Address(magic: magic, publicKey: identity.publicKey)
//        
//        let tokenDefinitionParticle = TokenDefinitionParticle(
//            symbol: "XRD",
//            name: "Rads",
//            description: "Native currency of Radix",
//            address: address
//        )
//        
//        return [tokenDefinitionParticle.withSpin().wrapInGroup()]
//    }()
//    
//    
//    func testThatPowIsIncludedInDsonOutputAllButExcludedInDsonOutputHash() {
//        guard let pow = doPow(worker: powWorker, atom: atom, magic: magic, numberOfLeadingZeros: numberOfLeadingZeros) else {
//            return XCTFail("no pow")
//        }
//        let atomWithPow = try! AtomWithFee(atomWithoutPow: atom, proofOfWork: pow)
//        let atomWithoutPowDsonAll = try! atom.toDSON(output: .all)
//        let atomWithPowDsonAll = try! atomWithPow.toDSON(output: .all)
//        
//        XCTAssertNotEqual(
//            atomWithoutPowDsonAll,
//            atomWithPowDsonAll,
//            "POW should be present when using `DSONOutput.all`, which should make an 'Atom without Pow' != 'Atom with Pow'"
//        )
//        
//        let atomWithoutPowDsonHash = try! atom.toDSON(output: .hash)
//        let atomWithPowDsonHash = try! atomWithPow.toDSON(output: .hash)
//        
//        XCTAssertNotEqual(atomWithoutPowDsonHash, atomWithPowDsonHash)
//        
//        let proofOfWorkDsonString = try! MetaDataKey.proofOfWork.stringValue.toDSON(output: .all).hex
//
//        XCTAssertTrue(atomWithPowDsonAll.hex.contains(proofOfWorkDsonString))
//        XCTAssertTrue(atomWithPowDsonHash.hex.contains(proofOfWorkDsonString))
//    }
//}
//
