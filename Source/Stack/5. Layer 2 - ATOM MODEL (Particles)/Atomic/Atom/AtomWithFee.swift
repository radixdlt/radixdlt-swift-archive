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

public struct AtomWithFee:
    AtomContainer,
    Throwing
{
    // swiftlint:enable colon opening_brace
    
    public let wrappedAtom: Atom
    
    public init(atomWithoutPow: Atomic, proofOfWork: ProofOfWork) throws {
        if let existingPowNonce = atomWithoutPow.metaData[.proofOfWork] {
            throw Error.atomAlreadyContainedPow(powNonce: existingPowNonce)
        }
        
        self.wrappedAtom = atomWithoutPow.withProofOfWork(proofOfWork)
    }
    
    public init(atomWithPow: Atomic) throws {
        guard atomWithPow.metaData.valueFor(key: .proofOfWork) != nil else {
            throw Error.atomDoesNotContainPow
        }
        self.wrappedAtom = Atom(atomic: atomWithPow)
    }
}

// MARK: - Throwing
public extension AtomWithFee {
    enum Error: Swift.Error {
        case atomAlreadyContainedPow(powNonce: String)
        case atomDoesNotContainPow
    }
}

// MARK: - Atomic + PoW
private extension Atomic {
    func withProofOfWork(_ proof: ProofOfWork) -> Atom {
        let atom = Atom(
            metaData: metaData.withProofOfWork(proof),
            signatures: signatures,
            particleGroups: particleGroups
        )
        return atom
    }
}
