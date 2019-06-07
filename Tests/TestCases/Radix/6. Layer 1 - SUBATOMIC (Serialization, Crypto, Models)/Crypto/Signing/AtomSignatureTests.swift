//
//  AtomSignatureTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class AtomSignatureTests: XCTestCase {

    private let powWorker = DefaultProofOfWorkWorker()
    
    func testSignatures() {
        
        // GIVEN
        // A RadixIdentity `alice`
        let magic: Magic = 1
        let alice = RadixIdentity(private: 1, magic: magic)
        
        // ... a simple Atom
        let atom = Atom(metaData: .timeNow)

        // WHEN
        // Alice signs the atom
        guard let signedAtom: SignedAtom = try? {
            guard
                let pow = doPow(worker: powWorker, atom: atom, magic: 2, numberOfLeadingZeros: 2, timeout: 1),
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
        let bob = RadixIdentity(private: 2, magic: magic)
        
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
