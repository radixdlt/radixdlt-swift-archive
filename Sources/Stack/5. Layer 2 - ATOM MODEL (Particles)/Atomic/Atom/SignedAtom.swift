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
        return "SignedAtom(aid: \(atomWithFee.shortAid)"
    }
}
