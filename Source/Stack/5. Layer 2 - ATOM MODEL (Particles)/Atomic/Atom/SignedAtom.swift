//
//  SignedAtom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SignedAtom: AtomConvertible, SignableConvertible {
    
    public enum Error: Swift.Error {
        case atomIsNotSigned
        case atomSignaturesDoesNotContainId
    }
    
    public let atom: ProofOfWorkedAtom
    public let signatureId: EUID
    public let signature: Signature
    
    public init(proofOfWorkAtom: ProofOfWorkedAtom, signatureId: EUID) throws {
        guard !proofOfWorkAtom.signatures.isEmpty else {
            throw Error.atomIsNotSigned
        }
        guard let signature = proofOfWorkAtom.signatures[signatureId] else {
            throw Error.atomSignaturesDoesNotContainId
        }
        self.atom = proofOfWorkAtom
        self.signatureId = signatureId
        self.signature = signature
    }
}

// MARK: AtomConvertible
public extension SignedAtom {
    var atomic: Atomic {
        return atom
    }
}

// MARK: SignableConvertible
public extension SignedAtom {
    var signable: Signable {
        return atom.signable
    }
}
