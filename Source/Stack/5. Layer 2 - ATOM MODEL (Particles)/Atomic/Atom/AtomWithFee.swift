//
//  AtomWithFee.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct AtomWithFee:
    AtomContainer,
    Throwing
{
    // swiftlint:enable colon opening_brace
    
    public let wrappedAtom: Atom
    
    public init(atomWithoutPow: Atomic, proofOfWork: ProofOfWork) throws {
        if let existingPowNonce = atomWithoutPow.metaData[.proofOfWork] {
            throw Error.atomAlreadyContainedPow(powNonce: existingPowNonce)
        }
        
        self.wrappedAtom = atomWithoutPow.withProofOfWork(proofOfWork)
    }
    
    public init(atomWithPow: Atomic) throws {
        guard atomWithPow.metaData.valueFor(key: .proofOfWork) != nil else {
            throw Error.atomDoesNotContainPow
        }
        self.wrappedAtom = Atom(atomic: atomWithPow)
    }
}

// MARK: - Throwing
public extension AtomWithFee {
    enum Error: Swift.Error {
        case atomAlreadyContainedPow(powNonce: String)
        case atomDoesNotContainPow
    }
}

// MARK: - Atomic + PoW
private extension Atomic {
    func withProofOfWork(_ proof: ProofOfWork) -> Atom {
        let atom = Atom(
            metaData: metaData.withProofOfWork(proof),
            signatures: signatures,
            particleGroups: particleGroups
        )
        return atom
    }
}
