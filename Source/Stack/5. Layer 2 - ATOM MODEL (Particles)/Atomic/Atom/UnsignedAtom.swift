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
    func signed(signature: Signature, signatureId: SignatureId) -> SignedAtom {
        return wrappedAtom.withSignature(signature, signatureId: signatureId)
    }
}

private extension AtomWithFee {
    func withSignature(_ signature: Signature, signatureId: SignatureId) -> SignedAtom {
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
