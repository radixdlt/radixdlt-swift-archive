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
import XCTest
@testable import RadixSDK

//class AtomSignatureTests: XCTestCase {
//
//    private let powWorker = DefaultProofOfWorkWorker()
//    
//    func testSignatures() {
//        
//        // GIVEN
//        // A RadixIdentity `alice`
//        let magic: Magic = 1
//        let alice = RadixIdentity(private: 1, magic: magic)
//        
//        // ... a simple Atom
//        let atom = Atom(metaData: .timeNow)
//
//        // WHEN
//        // Alice signs the atom
//        guard let signedAtom: SignedAtom = try? {
//            guard
//                let pow = doPow(worker: powWorker, atom: atom, magic: 2, numberOfLeadingZeros: 2, timeout: 1),
//                let atomWithPow = XCTAssertNotThrows(
//                    try AtomWithFee(atomWithoutPow: atom, proofOfWork: pow)
//                ),
//                let unsignedAtom = XCTAssertNotThrows(
//                    try UnsignedAtom(atomWithPow: atomWithPow)
//                ),
//                let signedAtom = XCTAssertNotThrows(
//                    try alice.sign(atom: unsignedAtom)
//                )
//            else { return nil }
//            return signedAtom
//        }() else { return }
//        
//        XCTAssertNotThrowsAndEqual(
//            try alice.didSign(atom: signedAtom),
//            true,
//            // THEN
//            "We can verify that the signature was produced by Alice"
//        )
//        
//        // and Given another identity for Bob
//        let bob = RadixIdentity(private: 2, magic: magic)
//        
//        XCTAssertNotThrowsAndEqual(
//            // WHEN
//            // We check if Bob did sign the atom
//            try bob.didSign(atom: signedAtom),
//            false,
//            // THEN
//            "We can verify that the signature was NOT produced by Bob"
//        )
//    }
//}
