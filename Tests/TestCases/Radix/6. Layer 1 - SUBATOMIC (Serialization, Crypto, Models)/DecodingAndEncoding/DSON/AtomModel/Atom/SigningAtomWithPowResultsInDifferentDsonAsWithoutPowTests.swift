//
//  SigningAtomWithPowResultsInDifferentDsonAsWithoutPowTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-10.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest


class SigningAtomWithPowResultsInDifferentDsonAsWithoutPowTests: XCTestCase {
    private let powWorker = DefaultProofOfWorkWorker()
    private let numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = 1
    private let magic: Magic = 1337
    private lazy var identity = RadixIdentity(magic: magic)
    private lazy var atom: Atom = {
        let address = Address(magic: magic, publicKey: identity.publicKey)
        
        let tokenDefinitionParticle = TokenDefinitionParticle(
            symbol: "XRD",
            name: "Rads",
            description: "Native currency of Radix",
            address: address
        )
        
        return [tokenDefinitionParticle.withSpin().wrapInGroup()]
    }()
    
    
    func testThatPowIsIncludedInDsonOutputAllButExcludedInDsonOutputHash() {
        guard let pow = doPow(worker: powWorker, atom: atom, magic: magic, numberOfLeadingZeros: numberOfLeadingZeros) else {
            return XCTFail("no pow")
        }
        let atomWithPow = try! ProofOfWorkedAtom(atomWithoutPow: atom, proofOfWork: pow)
        let atomWithoutPowDsonAll = try! atom.toDSON(output: .all)
        let atomWithPowDsonAll = try! atomWithPow.toDSON(output: .all)
        
        XCTAssertNotEqual(
            atomWithoutPowDsonAll,
            atomWithPowDsonAll,
            "POW should be present when using `DSONOutput.all`, which should make an 'Atom without Pow' != 'Atom with Pow'"
        )
        
        let atomWithoutPowDsonHash = try! atom.toDSON(output: .hash)
        let atomWithPowDsonHash = try! atomWithPow.toDSON(output: .hash)
        
        XCTAssertNotEqual(atomWithoutPowDsonHash, atomWithPowDsonHash)
        
        let proofOfWorkDsonString = try! MetaDataKey.proofOfWork.stringValue.toDSON(output: .all).hex

        XCTAssertTrue(atomWithPowDsonAll.hex.contains(proofOfWorkDsonString))
        XCTAssertTrue(atomWithPowDsonHash.hex.contains(proofOfWorkDsonString))
    }
}

