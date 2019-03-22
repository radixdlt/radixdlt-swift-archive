//
//  AtomSigning.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AtomSigning {
    func sign(atom unsignedAtom: UnsignedAtom) throws -> SignedAtom
}

// MARK: - Default Implementation
public extension AtomSigning where Self: Signing, Self: Ownable {
    func sign(atom unsignedAtom: UnsignedAtom) throws -> SignedAtom {
        let signatureId = publicKey.hashId
        let signature = try Signer.sign(unsignedAtom, privateKey: privateKey)
        return unsignedAtom.signed(signature: signature, signatureId: signatureId)
    }
}
