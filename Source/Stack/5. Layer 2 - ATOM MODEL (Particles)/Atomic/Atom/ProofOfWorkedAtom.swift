//
//  ProofOfWorkedAtom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct ProofOfWorkedAtom: AtomConvertible, SignableConvertible {
    
    public enum Error: Swift.Error {
        case atomAlreadyContainedPow(powNonce: String)
        case atomDoesNotContainPow
    }
    
    public let atom: Atom
    
    public init(atomWithoutPow: Atomic, proofOfWork: ProofOfWork) throws {
        if let existingPowNonce = atomWithoutPow.metaData[.proofOfWork] {
            throw Error.atomAlreadyContainedPow(powNonce: existingPowNonce)
        }
        
        self.atom = atomWithoutPow.withProofOfWork(proofOfWork)
    }
    
    public init(atomWithPow: Atomic) throws {
        guard atomWithPow.metaData.valueFor(key: .proofOfWork) != nil else {
            throw Error.atomDoesNotContainPow
        }
        self.atom = Atom(atomic: atomWithPow)
    }
}

// MARK: - AtomConvertible
public extension ProofOfWorkedAtom {
    var atomic: Atomic { return atom }
}

// MARK: - SignableConvertible
public extension ProofOfWorkedAtom {
    var signable: Signable {
        return atom.signable
    }
}

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
