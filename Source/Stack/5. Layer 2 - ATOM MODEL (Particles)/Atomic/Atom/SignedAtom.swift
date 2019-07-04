//
//  SignedAtom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct SignedAtom:
    AtomContainer,
    Throwing,
    CustomStringConvertible
{
    // swiftlint:enable colon opening_brace
    
    public let atomWithFee: AtomWithFee
    public let signatureId: EUID
    public let signature: Signature
    
    public init(proofOfWorkAtom: AtomWithFee, signatureId: EUID) throws {
        guard !proofOfWorkAtom.signatures.isEmpty else {
            throw Error.atomIsNotSigned
        }
        guard let signature = proofOfWorkAtom.signatures[signatureId] else {
            throw Error.atomSignaturesDoesNotContainId
        }
        self.atomWithFee = proofOfWorkAtom
        self.signatureId = signatureId
        self.signature = signature
    }
}

// MARK: - Throwing
public extension SignedAtom {
    enum Error: Swift.Error {
        case atomIsNotSigned
        case atomSignaturesDoesNotContainId
    }
}

// MARK: - AtomContainer
public extension SignedAtom {
    var wrappedAtom: AtomWithFee {
        return atomWithFee
    }
}

// MARK: - CustomStringConvertible
public extension SignedAtom {
    var description: String {
        return "SignedAtom(id: \(atomWithFee.identifier())"
    }
}
