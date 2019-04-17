//
//  UnsignedAtom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct UnsignedAtom: AtomConvertible, SignableConvertible {
    
    public enum Error: Swift.Error {
        case atomAlreadySigned
    }
    
    public let unsignedAtom: ProofOfWorkedAtom
    
    public init(atomWithPow: ProofOfWorkedAtom) throws {
        guard atomWithPow.signatures.isEmpty else {
            throw Error.atomAlreadySigned
        }
        self.unsignedAtom = atomWithPow
    }
}

// MARK: - AtomConvertible
public extension UnsignedAtom {
    var atomic: Atomic {
        return unsignedAtom
    }
}

// MARK: - SignableConvertible
public extension UnsignedAtom {
    var signable: Signable {
        return unsignedAtom
    }
}

// MARK: - Signing
public extension UnsignedAtom {
    func signed(signature: Signature, signatureId: EUID) -> SignedAtom {
        return unsignedAtom.withSignature(signature, signatureId: signatureId)
    }
}

private extension ProofOfWorkedAtom {
    func withSignature(_ signature: Signature, signatureId: EUID) -> SignedAtom {
        let atomWithPowAndSignature = Atom(
            metaData: metaData,
            signatures: signatures.inserting(value: signature, forKey: signatureId),
            particleGroups: particleGroups
        )
        
        do {
            let proofOfWorkAtomWithSignature = try ProofOfWorkedAtom(atomWithPow: atomWithPowAndSignature)
            return try SignedAtom(proofOfWorkAtom: proofOfWorkAtomWithSignature, signatureId: signatureId)
        } catch {
            incorrectImplementation("Should always be able to add signature to an atom")
        }
    }
}
