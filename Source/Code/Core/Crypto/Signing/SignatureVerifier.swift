//
//  SignatureVerifier.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import BitcoinKit

/// ECDSA signature verifier
public final class SignatureVerifier {}
public extension SignatureVerifier {
    
    /// Verifies that the ECDSA `Signature` did sign the `Message` using the `PublicKey`
    static func verifyThat(
        signature: Signature,
        signedMessage message: Message,
        usingKey publicKey: PublicKey
    ) throws -> Bool {
        return try verifyThat(signature: signature, didSignData: message, usingKey: publicKey)
    }
    
    static func verifyThat(
        signature: Signature,
        didSign signable: Signable,
        usingKey publicKey: PublicKey
    ) throws -> Bool {
        return try verifyThat(signature: signature, didSignData: signable.signableData, usingKey: publicKey)
    }
}

private extension SignatureVerifier {
    
    static func verifyThat(
        signature: Signature,
        didSignData dataConvertible: DataConvertible,
        usingKey publicKey: PublicKey
        ) throws -> Bool {
        
        let signatureDER = try signature.toDER()
        
        return try BitcoinKit.Crypto.verifySignature(
            signatureDER.asData,
            message: dataConvertible.asData,
            publicKey: publicKey.asData
        )
    }
  
}
