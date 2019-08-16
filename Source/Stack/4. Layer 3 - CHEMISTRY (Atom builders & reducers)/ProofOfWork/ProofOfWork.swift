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

public struct ProofOfWork: CustomStringConvertible, CustomDebugStringConvertible {
    
    private let seed: Data
    private let magic: Magic
    public let nonce: Nonce
    public let targetNumberOfLeadingZeros: NumberOfLeadingZeros
    
    internal init(seed: Data, targetNumberOfLeadingZeros: NumberOfLeadingZeros, magic: Magic, nonce: Nonce) {
        self.seed = seed
        self.targetNumberOfLeadingZeros = targetNumberOfLeadingZeros
        self.magic = magic
        self.nonce = nonce
        
        func logIfNonceExceedsThreshold(_ threshold: Nonce = 300_000) {
            guard nonce.value > threshold.value else { return }
            log.info("POW high nonce, might be useful for tests, NONCE: \(nonce.value), FROM: magic: \(magic), seed: \(seed.hex), #zeros: \(targetNumberOfLeadingZeros)")
        }
        logIfNonceExceedsThreshold()
    }
}

// MARK: - Prove
public extension ProofOfWork {
    @discardableResult
    func prove() throws -> ProofOfWork {
        let hashed = hash()
        let numberOfLeadingZeros = hashed.numberOfLeadingZeroBits
        if numberOfLeadingZeros < targetNumberOfLeadingZeros {
            throw Error.tooFewLeadingZeros(
                expectedAtLeast: targetNumberOfLeadingZeros.numberOfLeadingZeros,
                butGot: UInt8(numberOfLeadingZeros)
            )
        }
        return self
    }
}

// MARK: - Public
public extension ProofOfWork {
    var nonceAsString: String {
        return nonce.description
    }
}

// MARK: CustomStringConvertible
public extension ProofOfWork {
    var description: String {
        return nonceAsString
    }
}

// MARK: CustomDebugStringConvertible
public extension ProofOfWork {
    var debugDescription: String {
        return """
            nonce: \(nonceAsString),
            hashHex: \(hash().hex)
        """
    }
}

// MARK: - Error
public extension ProofOfWork {
    enum Error: Swift.Error {
        case workInputIncorrectLengthOfSeed(expectedByteCountOf: Int, butGot: Int)
        case tooFewLeadingZeros(expectedAtLeast: UInt8, butGot: UInt8)
    }
}

// MARK: - Private
private extension ProofOfWork {
    func hash() -> RadixHash {
        let unhashed: Data = magic.toFourBigEndianBytes() + seed + nonce.toEightBigEndianBytes()
        
        return RadixHash(unhashedData: unhashed)
    }
}

// MARK: - Endianess (Matching Java library ByteStream `putLong`)
internal extension Nonce {
    func toEightBigEndianBytes() -> [Byte] {
        let nonce8Bytes = CFSwapInt64HostToBig(UInt64(value)).bytes
        assert(nonce8Bytes.count == 8)
        return nonce8Bytes
    }
}
