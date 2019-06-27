//
//  UnsignedAtom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct UnsignedAtom:
    AtomContainer,
    Throwing
{
    // swiftlint:enable colon opening_brace

    public let wrappedAtom: AtomWithFee
    
    public init(atomWithPow: AtomWithFee) throws {
        guard atomWithPow.signatures.isEmpty else {
            throw Error.atomAlreadySigned
        }
        self.wrappedAtom = atomWithPow
    }
}

// MARK: - Throwing
public extension UnsignedAtom {
    enum Error: Swift.Error {
        case atomAlreadySigned
    }
}

// MARK: - Signing
public extension UnsignedAtom {
    func signed(signature: Signature, signatureId: EUID) -> SignedAtom {
        return wrappedAtom.withSignature(signature, signatureId: signatureId)
    }
}

private extension AtomWithFee {
    func withSignature(_ signature: Signature, signatureId: EUID) -> SignedAtom {
        let atomWithPowAndSignature = Atom(
            metaData: metaData,
            signatures: signatures.inserting(value: signature, forKey: signatureId),
            particleGroups: particleGroups
        )
        
        do {
            let proofOfWorkAtomWithSignature = try AtomWithFee(atomWithPow: atomWithPowAndSignature)
            return try SignedAtom(proofOfWorkAtom: proofOfWorkAtomWithSignature, signatureId: signatureId)
        } catch {
            incorrectImplementation("Should always be able to add signature to an atom")
        }
    }
}
