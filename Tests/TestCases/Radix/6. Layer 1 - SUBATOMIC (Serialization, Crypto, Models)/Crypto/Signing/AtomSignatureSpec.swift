//
//  AtomSignatureSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class AtomSignatureTests: XCTestCase {

    
    func testSignatures() {
        
        // GIVEN
        // A RadixIdentity `alice`
        let alice: RadixIdentity = 1
        
        // ... a simple Atom
        let atom = Atom(metaData: .timeNow)

        // WHEN
        // Alice signs the atom
        guard let signedAtom: SignedAtom = try? {
            guard
                let pow = ProofOfWork.work(atom: atom, magic: 2, numberOfLeadingZeros: 2, timeout: 1),
                let atomWithPow = XCTAssertNotThrows(
                    try ProofOfWorkedAtom(atomWithoutPow: atom, proofOfWork: pow)
                ),
                let unsignedAtom = XCTAssertNotThrows(
                    try UnsignedAtom(atomWithPow: atomWithPow)
                ),
                let signedAtom = XCTAssertNotThrows(
                    try alice.sign(atom: unsignedAtom)
                )
            else { return nil }
            return signedAtom
        }() else { return }
        
        XCTAssertNotThrowsAndEqual(
            try alice.didSign(atom: signedAtom),
            true,
            // THEN
            "We can verify that the signature was produced by Alice"
        )
        
        // and Given another identity for Bob
        let bob: RadixIdentity = 2
        
        XCTAssertNotThrowsAndEqual(
            // WHEN
            // We check if Bob did sign the atom
            try bob.didSign(atom: signedAtom),
            false,
            // THEN
            "We can verify that the signature was NOT produced by Bob"
        )
    }
}
