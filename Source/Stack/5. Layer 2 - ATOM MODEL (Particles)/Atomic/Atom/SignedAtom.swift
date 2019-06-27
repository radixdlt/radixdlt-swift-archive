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
    Throwing
{
    // swiftlint:enable colon opening_brace
    
    private let proofOfWorkAtom: AtomWithFee
    public let signatureId: EUID
    public let signature: Signature
    
    public init(proofOfWorkAtom: AtomWithFee, signatureId: EUID) throws {
        guard !proofOfWorkAtom.signatures.isEmpty else {
            throw Error.atomIsNotSigned
        }
        guard let signature = proofOfWorkAtom.signatures[signatureId] else {
            throw Error.atomSignaturesDoesNotContainId
        }
        self.proofOfWorkAtom = proofOfWorkAtom
        self.signatureId = signatureId
        self.signature = signature
    }
}

// MARK: - Throwin
public extension SignedAtom {
    enum Error: Swift.Error {
        case atomIsNotSigned
        case atomSignaturesDoesNotContainId
    }
}

// MARK: - AtomContainer
public extension SignedAtom {
    var wrappedAtom: AtomWithFee {
        return proofOfWorkAtom
    }
}
