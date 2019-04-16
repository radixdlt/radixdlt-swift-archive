//
//  SignedAtom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SignedAtom {
    
    public enum Error: Swift.Error {
        case atomIsNotSigned
        case atomSignaturesDoesNotContainId
    }
    
    public let atom: Atom
    public let signatureId: EUID
    public let signature: Signature
    
    public init(atom: Atom, signatureId: EUID) throws {
        guard !atom.signatures.isEmpty else {
            throw Error.atomIsNotSigned
        }
        guard let signature = atom.signatures[signatureId] else {
            throw Error.atomSignaturesDoesNotContainId
        }
        self.atom = atom
        self.signatureId = signatureId
        self.signature = signature
    }
}
