//
//  EmptyAtomSignatureTests.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import XCTest
@testable import RadixSDK

class EmptyAtomSignatureTests: XCTestCase {
    func testHashIdOfEmptyAtom() {
        // GIVEN
        // An "empty" atom
        let atom = Atom(metaData: ChronoMetaData.timestamp(0))
        
        // WHEN
        // I calculate the hashEUID
        let hashEUID = atom.hashEUID
        
        // THEN
        // It should match the hashEUID produced by the Java library
        let calculatedByJavaLib: EUID = "e50964da69e6672a98d5e3c1b1d73fb3"
        XCTAssertEqual(
            hashEUID,
            calculatedByJavaLib,
            "should match java lib"
        )
    }
    
    func testSig() {
        // GIVEN
        // An "empty" atom
        let atom = Atom(metaData: ChronoMetaData.timestamp(0))
        // and the private key derived from the seed "Radix"
        
        // WHEN
        // I sign the empty atom with the seeded private key
        let seed = Sha256Hasher().hash(data: "Radix".toData())
        guard let privateKey = XCTAssertNotThrows(
            try PrivateKey(data: seed)
        ) else { return }
        
        guard let signature = XCTAssertNotThrows(
            try Signer.sign(atom, privateKey: privateKey)
        ) else { return }
      
        // THEN
        // The signature should match the one produced by the Java lib
        XCTAssertEqual(
            signature.r.hex,
            "d58c086f3d79a4159241df186306ff21627f09d718820a886110ee927dfc6682",
            "`R` part in signature should match java lib"
        )
        XCTAssertEqual(
            signature.s.hex,
            "63a573d3255f529310c6db9a985b01cba72fdcf4236b1e12f64ecac2e2ddce14",
            "`S` part in signature should match java lib"
        )
    }
}
