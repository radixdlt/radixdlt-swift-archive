//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import BitcoinKit

/// ECDSA signature verifier
public final class SignatureVerifier {}
public extension SignatureVerifier {
    
    /// Verifies that the ECDSA `Signature` did sign the `Message` using the `PublicKey`
    static func verifyThat(
        signature: Signature,
        signedMessage message: SignableMessage,
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
