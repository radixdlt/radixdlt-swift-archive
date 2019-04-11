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
    
    private let numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = 1
    private let magic: Magic = 1337
    private let identity = RadixIdentity()
    private lazy var atom: Atom = {
        let address = Address(publicKey: identity.publicKey)
        
        let tokenDefinitionParticle = TokenDefinitionParticle(
            symbol: "XRD",
            name: "Rads",
            description: "Native currency of Radix",
            address: address
        )
        
        return [tokenDefinitionParticle.withSpin().wrapInGroup()]
    }()
    
    
    func testThatOrderOfSigningAndPowDoesNotMatter() {
        let signedAtomWithoutPow = try! identity.sign(atom: UnsignedAtom(atom))
        let signedAtomWithPow = try! identity.sign(atom: UnsignedAtom(atom.withProofOfWork(magic: magic, numberOfLeadingZeros: numberOfLeadingZeros)))
        XCTAssertEqual(signedAtomWithoutPow.signature, signedAtomWithPow.signature)
    }
    
    func testThatPowIsIncludedInDsonOutputAllButExcludedInDsonOutputHash() {
        let atomWithPow = try! atom.withProofOfWork(magic: magic, numberOfLeadingZeros: numberOfLeadingZeros)
        
        let atomWithoutPowDsonAll = try! atom.toDSON(output: .all)
        let atomWithPowDsonAll = try! atomWithPow.toDSON(output: .all)
        
        XCTAssertNotEqual(
            atomWithoutPowDsonAll,
            atomWithPowDsonAll,
            "POW should be present when using `DSONOutput.all`, which should make an 'Atom without Pow' != 'Atom with Pow'"
        )
        
        let atomWithoutPowDsonHash = try! atom.toDSON(output: .hash)
        let atomWithPowDsonHash = try! atomWithPow.toDSON(output: .hash)
        
        XCTAssertEqual(atomWithoutPowDsonHash, atomWithPowDsonHash)
        
        let proofOfWorkDsonString = try! MetaDataKey.proofOfWork.stringValue.toDSON(output: .all).hex

        XCTAssertTrue(atomWithPowDsonAll.hex.contains(proofOfWorkDsonString))
        XCTAssertFalse(atomWithPowDsonHash.hex.contains(proofOfWorkDsonString))
    }
}

