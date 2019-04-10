//
//  SigninAtomWithPowResultsInSameDsonAsWithoutPowTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-10.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

class SigninAtomWithPowResultsInSameDsonAsWithoutPowTests: XCTestCase {
    func testThatOrderOfSigningAndPowDoesNotMatter() {
        let magic: Magic = 1337
        let identity = RadixIdentity()
        let address = Address(publicKey: identity.publicKey)
        
        let tokenDefinitionParticle = TokenDefinitionParticle(
            symbol: "XRD",
            name: "Rads",
            description: "Native currency of Radix",
            address: address
        )
        
        let atom: Atom = [tokenDefinitionParticle.withSpin().wrapInGroup()]
        
        let signedAtomWithoutPow = try! identity.sign(atom: UnsignedAtom(atom))
        let signedAtomWithPow = try! identity.sign(atom: UnsignedAtom(atom.withProofOfWork(magic: magic)))
        XCTAssertEqual(signedAtomWithoutPow.signature, signedAtomWithPow.signature)
        
    }
}

